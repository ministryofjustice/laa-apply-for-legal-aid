FactoryBot.define do
  factory :address do
    applicant
    address_line_one { Faker::Address.building_number }
    address_line_two { Faker::Address.street_address }
    city { Faker::Address.city }
    county { Faker::Address.city }
    country_code { "GBR" }
    country_name { "United Kingdom" }
    postcode { ["SW10 9LB", "W6 0LQ", "SW1A 1AA", "RG2 7PU", "BH22 7HR"].sample }
    building_number_name { "" }
    location { "correspondence" }

    trait :is_lookup_used do
      lookup_used { true }
    end

    trait :with_address_for_xml_fixture do
      postcode { "GH08NY" }
    end

    trait :as_home_address do
      location { "home" }
    end
  end
end
