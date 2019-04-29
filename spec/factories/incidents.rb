FactoryBot.define do
  factory :incident do
    told_on { Faker::Date.backward(90) }
    occurred_on { Faker::Date.backward(90) }
    details { Faker::Lorem.paragraph }
    legal_aid_application
  end
end
