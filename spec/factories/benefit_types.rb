FactoryBot.define do
  factory :benefit_type do
    sequence :label do |n|
      "benefit_type_#{n}"
    end
    description { Faker::Lorem.paragraph }
    exclude_from_gross_income { [true, false].sample }
  end
end
