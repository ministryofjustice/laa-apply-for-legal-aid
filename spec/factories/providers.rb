FactoryBot.define do
  factory :provider do
    username { Faker::Internet.user_name }
  end
end
