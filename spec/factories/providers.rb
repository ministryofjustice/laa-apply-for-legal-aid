FactoryBot.define do
  factory :provider do
    firm
    name { Faker::Name.name }
    username { Faker::Internet.unique.username }
    email { Faker::Internet.safe_email }

    trait :with_provider_details_api_username do
      username { 'NEETADESOR' }
    end
  end
end
