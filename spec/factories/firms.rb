FactoryBot.define do
  factory :firm do
    ccms_id { rand(1..1000) }
    name { Faker::Company.name }
  end

  trait :with_no_permissions do
    permissions { [] }
  end
end
