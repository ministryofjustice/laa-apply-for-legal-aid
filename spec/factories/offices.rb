FactoryBot.define do
  factory :office do
    ccms_id { Faker::Number.unique.number(10) }
    code { Faker::Number.unique.number(10) }
    firm
  end
end
