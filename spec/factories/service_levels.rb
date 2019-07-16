FactoryBot.define do
  factory :service_level do
    service_id { Faker::Number.number(2).to_i }
    name { Faker::Lorem.sentence }

    trait :with_real_data do
      service_id { 3 }
      name { 'Full Representation' }
    end

    initialize_with { ServiceLevel.find_or_create_by(service_id: service_id) }
  end
end
