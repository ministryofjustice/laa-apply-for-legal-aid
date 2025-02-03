FactoryBot.define do
  factory :firm do
    ccms_id { rand(1..1000) }
    name { Faker::Company.name }
  end

  trait :with_no_permissions do
    permissions { [] }
  end

  trait :with_dummy_permission do
    permissions do
      dummy_permission = create(:permission, :dummy_permission)
      [dummy_permission]
    end
  end
end
