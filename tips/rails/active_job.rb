# 基本、serviceクラスのメソッド実行と引数の受け渡しだけにする
class CreateUsersJob < ApplicationJob
  queue_as :default

  def perform
    month = Date.today.beginning_of_month - 1.month
    UserServices::CreateUsers.new(month: month).execute!
  end
end

# 実行
CreateUsersJob.perform_later([引数])