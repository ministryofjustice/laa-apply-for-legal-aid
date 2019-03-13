FactoryBot.define do
  factory :incident do
    occurred_on { Faker::Date.backward(90) }
    details { Faker::Lorem.paragraph }
    legal_aid_application
  end
end
