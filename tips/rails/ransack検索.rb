
# http://nekorails.hatenablog.com/entry/2017/05/31/173925

# 基本
Model.ransack(params)

# 比較
_eq 等しい
_cnt 含む
first_name_or_last_name_or_nickname_cont 複数カラムを連結
comments_body_eq 関連 has_one
post_title_eq 関連 has_many
post_user_name_eq 孫関連 1_関連先2_関連先2のカラム_述語

# controller
before_action :set_search, only: %i[index]
def set_search
  @search_params = params.fetch(:q, {}).permit!
  @q = User.search(@search_params) # ransackの拡張なのでmodelには基本は何も書く必要はない
  @users = @q.result.page(params[:page])
end

# model user.rb where句をカスタムしたい場合
# formatter: 右辺, ブロック内: 左辺
ransacker :phone_number_search, formatter: -> value { value.gsub("-", "") } do
  Arel::Nodes::SqlLiteral.new "REPLACE(users.phone_number, '-', '')"
end

# 列選択でソート
= sort_link(@q, :id, 'user_id', default_order: :desc, hide_indicator: true))

# (可能なら)条件指定が適切でない場合は、例外を投げるのが良さげ
# config/initializers/ransack.rb
Ransack.configure do |config|
  config.ignore_unknown_conditions = false
end