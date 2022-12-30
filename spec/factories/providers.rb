FactoryBot.define do
  factory :provider do
    firm
    name { Faker::Name.name }
    username { "#{Faker::Internet.username}_#{Random.rand(1...999).to_s.rjust(3, '0')}" }
    email { Faker::Internet.safe_email }
    portal_enabled { true }

    trait :without_portal_enabled do
      portal_enabled { false }
    end

    trait :with_provider_details_api_username do
      username { "NEETADESOR" }
    end

    trait :with_bank_statement_upload_permissions do
      permissions do
        bank_statement_upload = Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
        bank_statement_upload = create(:permission, :bank_statement_upload) if bank_statement_upload.nil?
        [bank_statement_upload]
      end
    end

    trait :with_full_section_8_permissions do
      permissions do
        full_section_8 = Permission.find_by(role: "application.full_section_8.*")
        full_section_8 = create(:permission, :full_section_8) if full_section_8.nil?
        [full_section_8]
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
      roles { "EMI,PUI_XXCCMS_BILL_PREPARATION,CWA_eFormsFirmAdministrator,PUI_XXCCMS_CROSS_OFFICE_ACCESS,EFORMS,CWA_XXLSC_EM_ACT_MGR_EXT" }
    end

    trait :with_ccms_apply_role do
      roles { "EMI,PUI_XXCCMS_BILL_PREPARATION,CWA_eFormsFirmAdministrator,CCMS_Apply,PUI_XXCCMS_CROSS_OFFICE_ACCESS,EFORMS,CWA_XXLSC_EM_ACT_MGR_EXT" }
    end
  end
end
