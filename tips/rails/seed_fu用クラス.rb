# db/fixtures/import_user.rb
require 'csv'

class ImportUser
  DIR = 'db/fixtures/users/'
  FILES = ['users.csv']

  class << self
    def execute!
      FILES.each do |file|
        file = "#{DIR}#{file}"
        CSV.foreach(file, encoding: "Shift_JIS:UTF-8") do |row|
          user = user_attrs(row)
          create_user(user)
        end
      end
    end

    def user_attrs(row)
      {
        name: row[0],
        code: row[1]
      }
    end

    def create_user(user_attrs)
      User.seed do |user|
        user.name = user_attrs[:name]
        user.code = user_attrs[:code]
      end
    end
  end
end
ImportUser.execute!
