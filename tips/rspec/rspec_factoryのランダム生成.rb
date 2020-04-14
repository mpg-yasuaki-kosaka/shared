# FFakerというgemが良さげ
# ユニークならSecureRandomも組み合わせる
trait :random_title do
  after(:build) do |model|
    model.title = "#{SecureRandom.alphanumeric(5)} #{FFaker::Music.band}"
  end
end

# sequenceも一応使えるけどrails再起動でリセットされるのでランダム生成としては微妙
  trait :random_email do
    email "#{SecureRandom.hex(30)}@test.co.jp"
    # rand = 30.times.map{SecureRandom.hex(30)[rand(29)]}.join
    # email "#{rand}@test.co.jp"
    sequence(:email){|n| "#{SecureRandom.hex(30)}_#{n}@fuga.com"}
  end
