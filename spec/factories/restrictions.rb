FactoryBot.define do
  factory :restriction do
    name { Faker::Commerce.product_name.underscore }

    trait :with_standard_name do
      sequence(:name) { |n| Restriction::NAMES[n.to_i - 1] }
    end
  end
end
