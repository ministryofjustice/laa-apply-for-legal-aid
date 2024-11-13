FactoryBot.define do
  factory :firm do
    ccms_id { rand(1..1000) }
    name { Faker::Company.name }
  end

  trait :with_sca_permissions do
    permissions do
      sca = Permission.find_by(role: "special_children_act")
      sca = create(:permission, :special_children_act) if sca.nil?
      [sca]
    end
  end

  trait :with_no_permissions do
    permissions { [] }
  end
end
