FactoryBot.define do
  factory :provider do
    firm
    name { Faker::Name.name }
    username { "#{Faker::Internet.username}_#{Random.rand(1...999).to_s.rjust(3, '0')}" }
    email { Faker::Internet.email }
    portal_enabled { true }

    trait :without_portal_enabled do
      portal_enabled { false }
    end

    trait :with_provider_details_api_username do
      username { "NEETADESOR" }
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

    trait :created_by_devise do
      firm { nil }
      name { nil }
      permissions { [] }
      sign_in_count { 0 }
    end

    trait :without_ccms_apply_role do
      roles { "EMI,PUI_XXCCMS_BILL_PREPARATION,CWA_eFormsFirmAdministrator,PUI_XXCCMS_CROSS_OFFICE_ACCESS,EFORMS,CWA_XXLSC_EM_ACT_MGR_EXT" }
    end

    trait :with_ccms_apply_role do
      roles { "EMI,PUI_XXCCMS_BILL_PREPARATION,CWA_eFormsFirmAdministrator,CCMS_Apply,PUI_XXCCMS_CROSS_OFFICE_ACCESS,EFORMS,CWA_XXLSC_EM_ACT_MGR_EXT" }
    end
  end
end
