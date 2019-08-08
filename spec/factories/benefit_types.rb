FactoryBot.define do
  factory :benefit_type do
    name { 'MyString' }
    description { 'MyText' }
    exclude_from_gross_income { false }
  end
end
