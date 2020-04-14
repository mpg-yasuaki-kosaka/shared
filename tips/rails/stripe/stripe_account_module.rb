# app/models/user.rb でincludeしてつかう
# stripeのapi(gem)を使ったものなので流用可
# StripeAccountEntityを使うべきだったかどうかは微妙
require 'active_support/concern'
module User::StripeAccountModule
  extend ActiveSupport::Concern

  concerning :StripeAccount do
    def stripe_account
      StripeAccountEntity.new_by_stripe_object( raw_stripe_account ) if raw_stripe_account
    end

    # stripe gem の生オブジェクト
    def raw_stripe_account(reload: false)
      return @raw_stripe_account if defined?(@raw_stripe_account) && !reload
      return @raw_stripe_account = nil unless stripe_account_id
      @raw_stripe_account = Stripe::Account.retrieve(stripe_account_id)
    end

    def create_or_update_stripe_account(params)
      stripe_account_id.blank? ? create_stripe_account(params) : update_stripe_account(params)
    end

    def create_stripe_account(params)
      p = StripeAccountEntity.to_stripe_params(params.merge(type: "custom", email: email))
      account = Stripe::Account.create(p)
      self.stripe_account_id = account.id
      self.save
      raw_stripe_account(reload: true)
    end

    def update_stripe_account(params)
      stripe_account.update_stripe_account(params)
      raw_stripe_account(reload: true)
    end

    def delete_stripe_account
      raw_stripe_account.delete
      self.stripe_account_id = nil
      self.save
      raw_stripe_account(reload: true)
    end

    def upload_verification(file_params)
      temp_file_open(file_params) do |file|
        stripe_file = Stripe::FileUpload.create({
                        file: file,
                        purpose: 'identity_document'
                      })
        raw_stripe_account.legal_entity.verification.document = stripe_file.id
        raw_stripe_account.save
      end
    end

    # 画像が1つなら1つ目の画像。2つなら2つの画像を結合した画像を返す
    def create_file(params)
      file1 = decode(params[:file1])
      return file1 if params[:file2].blank?
      file2 = decode(params[:file2])
      file3 = nil
      create_temp_file(file1) do |temp_file1|
        create_temp_file(file2) do |temp_file2|
          file3 = Magick::ImageList.new(temp_file1, temp_file2)
          file3 = file3.append(true)
        end
      end
      file3.to_blob
    end

    def temp_file_open(params)
      file = create_file(params)
      create_temp_file(file) do |temp_file|
        yield temp_file
      end
    end

    def decode(file)
      base64_image = file.split(',', 2).last
      Base64.decode64(base64_image)
    end

    def create_temp_file(file)
      Tempfile.open(["", ".jpeg"]) do |t|
        t.binmode
        t.write(file)
        f2 = File.new(t.path) # Fileのインスタンスである必要がある
        yield f2
        f2.close
        t
      end
    end

    def accept_stripe_account_agreement(remote_ip: , user_agent: nil)
      raw_stripe_account.tos_acceptance.date = Time.now.to_i
      raw_stripe_account.tos_acceptance.ip = remote_ip
      raw_stripe_account.tos_acceptance.user_agent = user_agent if user_agent
      raw_stripe_account.save
    end

    # TODO: viewの方で呼ぶかも
    def validate_stripe_account(params)
      sa = StripeAccountEntity.new( params.merge(email: email) )
      sa.valid? ? nil : sa.errors
    end
  end

  concerning :BankAccount do
    def bank_account
      BankAccountEntity.new_by_stripe_object(raw_bank_account) if raw_bank_account
    end

    def raw_bank_account
      bank_accounts&.find{|bank_account| bank_account.default_for_currency == true}
    end

    def bank_accounts
      raw_stripe_account&.external_accounts&.select{|external_account| external_account["object"] == "bank_account" }
    end

    # stripeのオブジェクトなので扱いに注意
    def create_bank_account(params)
      old = raw_bank_account
      old.default_for_currency = false if old
      bank_account_params = BankAccountEntity.to_stripe_params( params.merge(account_holder_type: stripe_account.legal_type) )
      token = Stripe::Token.create( bank_account_params )
      new = raw_stripe_account.external_accounts.create(external_account: token.id)
      new.metadata = {account_type: params["account_type"]} # metadataはcreate時にセットできないので別途セットする
      new.default_for_currency = true
      new.save # oldも同時にsaveされる
      delete_old_bank_accounts(exclusion: new)

      raw_stripe_account(reload: true) # reload
      create_user_current_bank_account (params["account_type"])
      bank_accounts
    end

    def create_user_current_bank_account(account_type)
      if account_type == "current"
        ba = UserCurrentBankAccount.find_or_initialize_by(user_id: id)
        ba.save
      else
        user_current_bank_account.destroy if user_current_bank_account
      end
    end

    def delete_old_bank_accounts(exclusion:)
      bank_accounts.each do |ba|
        next if ba.id == exclusion.id
        ba.delete # stripe側からの提供メソッド
      end
    end

    # TODO: viewの方で呼ぶかも
    def validate_bank_account_params(params)
      ba = BankAccountEntity.new(params)
      ba.valid? ? nil : ba.errors
    end
  end

  concerning :Charge do
    # テスト用メソッド すぐに入金処理がされpayout可能となる
    def test_charge(amount)
      Stripe::Charge.create(
        amount: amount,
        currency: "jpy",
        source: "tok_bypassPending", # テスト用source
        description: "Charge for #{email}",
        destination: stripe_account_id
      )
    rescue Stripe::InvalidRequestError => e
      raise StandardError, "テスト入金でもアカウントを有効にする必要があります。アカウントの状態を確認してください。 " + \
                           "https://dashboard.stripe.com/test/applications/users/overview " + \
                           "エラー詳細: #{e}"
    end
  end

  concerning :Payout do
    # chargeかtransferをして残高を増やしておかないと使用できない
    def payout(amount)
      Stripe::Payout.create(
        {
          amount: amount,
          currency: "jpy",
          destination: raw_bank_account.id,
          description: "Payout to #{email}",
          statement_descriptor: Rails.application.config.x.stripe.statement_descriptor
        },
        { "Stripe-Account": stripe_account_id }
      )
      PayoutNotifiers::CompleteNotifier.complete(to: email, user_id: id).deliver_later
    end

    def payout_list(limit=100)
      Stripe::Payout.list(
        {limit: limit},
        { "Stripe-Account": stripe_account_id }
      ).data
    end
  end

  concerning :Transfer do
    def transfer(amount, transfer_group="")
      Stripe::Transfer.create(
        {
          amount: amount,
          currency: "jpy",
          destination: stripe_account_id,
          transfer_group: transfer_group.to_s
        }
      )
    end

    # デバッグ用。システム内未使用
    def raw_transfer_list(limit=100)
      Stripe::Transfer.list({
        limit: limit,
        destination: stripe_account_id
      })
    end

    # 月次サマリテーブルを作成して存在していればそこから取ってくるようにする(締め処理の実装時に)
    def transfer_summary(month)
      rs = transfer_reservations(month)
      {
        payout_balance: 0,
        sales:          rs.sum{|r|r[:sales].to_i},
        sales_fee:      rs.sum{|r|r[:sales_fee]},
        service_fee:    rs.sum{|r|r[:service_fee].to_i},
        net_sales:      rs.sum{|r|r[:net_sales]},
        status:         "未確定"
      }
    end

    def transfer_reservations(month, page=nil)
      host_reservations(month, page).to_a.map do |r|
        c = r.price_calculator
        {
          date:         r.checkout.strftime("%Y/%-m/%-d"),
          sales:        c.transfer_sales,
          sales_fee:    c.transfer_sales_fee,
          service_fee:  c.transfer_service_fee,
          net_sales:    c.transfer_net_sales,
          name:         r.room_group.room_title[:ja],
          payment_type: c.transfer_payment_type_name,
        }
      end
    end

    def host_reservations(month, page=nil)
      m = Date.parse(month)
      month_range = m.beginning_of_month..m.end_of_month
      reservations = Reservation
                     .joins(room_group: :property)
                     .where(checkout: month_range)
                     .where(properties: {user_id: id})
      reservations.page(page) if page
      reservations
    end
  end

  concerning :Balance do
    def available_balance
      raw_balance.available.find{|hash| hash["currency"] == "jpy"}["amount"] rescue 0
    end

    def pending_balance
      raw_balance.pending.find{|hash| hash["currency"] == "jpy"}["amount"] rescue 0
    end

    def raw_balance(reload: false)
      return @raw_balance if defined?(@raw_balance) && !reload
      return @raw_balance = nil unless stripe_account_id
      @raw_balance = Stripe::Balance.retrieve({"Stripe-Account": stripe_account_id})
    end
  end
end
