FactoryBot.define do
  factory :admin_user do
    username { Faker::Internet.username }
    report_only { false }
  end
end
