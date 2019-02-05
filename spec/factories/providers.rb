FactoryBot.define do
  factory :provider do
    username { Faker::Internet.unique.user_name }
  end
end
