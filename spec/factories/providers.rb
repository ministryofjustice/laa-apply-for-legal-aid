FactoryBot.define do
  factory :provider do
    firm
    name { Faker::Name.name }
    username { Faker::Internet.unique.username }
    email { Faker::Internet.safe_email }
    permissions do
      passported = Permission.find_by(role: 'application.passported.*')
      passported = create(:permission, :passported) if passported.nil?
      non_passported = Permission.find_by(role: 'application.non_passported.*')
      non_passported = create(:permission, :non_passported) if non_passported.nil?
      [passported, non_passported]
    end

    trait :with_provider_details_api_username do
      username { 'NEETADESOR' }
    end

    trait :with_passported_and_non_passported_permissions do
      permissions do
        passported = Permission.find_by(role: 'application.passported.*')
        passported = create(:permission, :passported) if passported.nil?
        non_passported = Permission.find_by(role: 'application.non_passported.*')
        non_passported = create(:permission, :non_passported) if non_passported.nil?
        [passported, non_passported]
      end
    end

    trait :with_passported_permissions do
      permissions do
        passported = Permission.find_by(role: 'application.passported.*')
        passported = create(:permission, :passported) if passported.nil?
        [passported]
      end
    end

    trait :with_non_passported_permissions do
      permissions do
        non_passported = Permission.find_by(role: 'application.non_passported.*')
        non_passported = create(:permission, :non_passported) if non_passported.nil?
        [non_passported]
      end
    end

    trait :with_no_permissions do
      permissions { [] }
    end
  end
end
