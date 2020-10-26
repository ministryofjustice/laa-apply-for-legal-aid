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
    portal_enabled { true }

    trait :without_portal_enabled do
      portal_enabled { false }
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

    trait :created_by_devise do
      firm { nil }
      name { nil }
      permissions { [] }
      sign_in_count { 0 }
    end

    trait :without_ccms_apply_role do
      roles { 'EMI,PUI_XXCCMS_BILL_PREPARATION,CWA_eFormsFirmAdministrator,PUI_XXCCMS_CROSS_OFFICE_ACCESS,EFORMS,CWA_XXLSC_EM_ACT_MGR_EXT' }
    end

    trait :with_ccms_apply_role do
      roles { 'EMI,PUI_XXCCMS_BILL_PREPARATION,CWA_eFormsFirmAdministrator,CCMS_Apply,PUI_XXCCMS_CROSS_OFFICE_ACCESS,EFORMS,CWA_XXLSC_EM_ACT_MGR_EXT' }
    end
  end
end
