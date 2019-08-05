FactoryBot.define do
  factory :vehicle do
    legal_aid_application

    trait :populated do
      estimated_value { Faker::Commerce.price(range: 2000..10_000) }
      payment_remaining { Faker::Commerce.price(range: 100..1_000) }
      purchased_on { Faker::Date.between(from: 20.years.ago, to: 2.days.ago) }
      used_regularly { Faker::Boolean.boolean }
    end
  end
end
