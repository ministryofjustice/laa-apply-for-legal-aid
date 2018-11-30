FactoryBot.define do
  factory :address do
    applicant
    address_line_one { Faker::Address.building_number }
    address_line_two { Faker::Address.street_address }
    city { Faker::Address.city }
    county { Faker::Address.city }
    postcode { Faker::Address.zip }

    trait :is_lookup_used do
      lookup_used { true }
    end
  end
end
