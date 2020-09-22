FactoryBot.define do
  factory :firm do
    ccms_id { rand(1..1000) }
    name { Faker::Company.name }
    with_passported_permissions
  end

  trait :with_passported_permissions do
    permissions { [Permission.find_by(role: 'application.passported.*') || create(:permission, :passported)] }
  end

  trait :with_non_passported_permissions do
    permissions { [Permission.find_by(role: 'application.non_passported.*') || create(:permission, :non_passported)] }
  end

  trait :with_no_permissions do
    permissions { [] }
  end

  trait :with_passported_and_non_passported_permissions do
    permissions do
      [
        Permission.find_by(role: 'application.passported.*') || create(:permission, :passported),
        Permission.find_by(role: 'application.non_passported.*') || create(:permission, :non_passported)
      ]
    end
  end
end
