FactoryBot.define do
  factory :benefit_check_result do
    legal_aid_application
    result { 'No' }
    dwp_ref { SecureRandom.hex }

    trait :positive do
      result { 'Yes' }
    end

    trait :negative do
      result { 'No' }
    end

    trait :undetermined do
      result { 'Undetermined' }
    end
  end
end
