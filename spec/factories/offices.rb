FactoryBot.define do
  factory :office do
    ccms_id { Faker::Number.unique.number(digits: 10).to_s }
    code { Faker::Number.unique.number(digits: 10).to_s }
    firm
  end
end
