FactoryBot.define do
  factory :provider do
    username { Faker::Internet.unique.user_name(10) }
  end
end
