FactoryBot.define do
  factory :vehicle do
    legal_aid_application

    trait :populated do
      estimated_value { Faker::Commerce.price(2000..10_000) }
      payment_remaining { Faker::Commerce.price(100..1_000) }
      purchased_on { Faker::Date.between(20.years.ago, 2.days.ago) }
      used_regularly { Faker::Boolean.boolean }
    end
  end
end
