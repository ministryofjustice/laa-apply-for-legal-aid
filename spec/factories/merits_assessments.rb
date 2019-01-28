FactoryBot.define do
  factory :merit_assessment do
    legal_aid_application
    client_received_legal_help { Faker::Boolean.boolean }
    application_purpose { Faker::Lorem.paragraph }
  end
end
