FactoryBot.define do
  factory :admin_user do
    username { Faker::Internet.username }
  end
end
