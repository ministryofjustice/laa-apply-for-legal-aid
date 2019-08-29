FactoryBot.define do
  factory :service_level do
    service_level_number { Faker::Number.number(digits: 2) }
    name { Faker::Lorem.sentence }

    trait :with_real_data do
      service_level_number { 3 }
      name { 'Full Representation' }
    end

    initialize_with { ServiceLevel.find_or_create_by(service_level_number: service_level_number) }
  end
end
