FactoryBot.define do
  factory :provider do
    username { Faker::Internet.unique.user_name(10) }

    trait :username_with_special_characters do
      username { 'Chloé.Doe' }
    end

    trait :with_provider_details_api_username do
      username { 'NEETADESOR' }
    end
  end
end
