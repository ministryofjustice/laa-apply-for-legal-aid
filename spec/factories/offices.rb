FactoryBot.define do
  factory :office do
    ccms_id { Faker::Number.unique.number(digits: 10).to_s }
    code { Faker::Number.unique.number(digits: 10).to_s }
    firm
  end

  trait :with_valid_schedule do
    schedules { build_list(:schedule, 1, :valid) }
  end
end
