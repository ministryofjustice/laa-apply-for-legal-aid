FactoryBot.define do
  factory :vehicle do
    legal_aid_application

    trait :populated do
      estimated_value { Faker::Commerce.price(range: 2000..10_000) }
      owner { "client" }
      payment_remaining { Faker::Commerce.price(range: 100..1_000) }
      more_than_three_years_old { true }
      used_regularly { Faker::Boolean.boolean }
    end

    trait :owned_by_partner do
      estimated_value { Faker::Commerce.price(range: 2000..10_000) }
      owner { "partner" }
      payment_remaining { Faker::Commerce.price(range: 100..1_000) }
      more_than_three_years_old { true }
      used_regularly { Faker::Boolean.boolean }
    end

    trait :with_applicant_and_partner do
      legal_aid_application { association(:legal_aid_application, :with_applicant_and_partner) }
    end
  end
end
