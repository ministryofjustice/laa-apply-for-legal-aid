FactoryBot.define do
  factory :service_level do
    service_id { Faker::Number.number(digits: 2) }
    name { Faker::Lorem.sentence }

    trait :with_real_data do
      service_id { 3 }
      name { 'Full Representation' }
    end

    initialize_with { ServiceLevel.find_or_create_by(service_id: service_id) }
  end
end
