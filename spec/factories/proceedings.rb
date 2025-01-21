FactoryBot.define do
  factory :proceeding do
    legal_aid_application
    substantive_level_of_service { "3" }
    substantive_level_of_service_name { "Full Representation" }
    substantive_level_of_service_stage { "8" }
    emergency_level_of_service { "3" }
    emergency_level_of_service_name { "Full Representation" }
    emergency_level_of_service_stage { "8" }
    sca_type { nil }

    sequence(:proceeding_case_id) { |n| n + 55_000_000 }

    trait :without_cit do
      client_involvement_type_ccms_code { nil }
      client_involvement_type_description { nil }
    end

    trait :with_cit_d do
      client_involvement_type_ccms_code { "D" }
      client_involvement_type_description { "Defendant/Respondent" }
    end

    trait :with_cit_z do
      client_involvement_type_ccms_code { "Z" }
      client_involvement_type_description { "Description for client involvement type Z" }
    end

    trait :without_df_date do
      used_delegated_functions { false }
    end

    trait :with_df_date do
      used_delegated_functions { true }
      used_delegated_functions_on { Faker::Date.between(from: 10.days.ago, to: 2.days.ago) }
      used_delegated_functions_reported_on { Time.zone.today }
    end

    trait :no_substantive_level_of_service do
      substantive_level_of_service { nil }
      substantive_level_of_service_name { nil }
      substantive_level_of_service_stage { nil }
    end

    transient do
      no_scope_limitations { false }
    end

    trait :da001 do
      lead_proceeding { true }
      ccms_code { "DA001" }
      meaning { "Inherent jurisdiction high court injunction" }
      description { "to be represented on an application for an injunction, order or declaration under the inherent jurisdiction of the court." }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { nil }
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { "inherent_jurisdiction_high_court_injunction" }
      matter_type { "Domestic Abuse" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "MINJN" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :da002 do
      lead_proceeding { false }
      ccms_code { "DA002" }
      meaning { "Variation or discharge under section 5 protection from harassment act 1997" }
      description do
        'to be represented on an application to vary or discharge an order under section 5 Protection from Harassment Act 1997
         where the parties are associated persons (as defined by Part IV Family Law Act 1996).'
      end
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { true }
      used_delegated_functions_on { Faker::Date.between(from: 10.days.ago, to: 2.days.ago) }
      used_delegated_functions_reported_on { Time.zone.today }
      name { "variation_or_discharge_under_section_protection_from_harassment_act" }
      matter_type { "Domestic Abuse" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "MINJN" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :da005 do
      lead_proceeding { false }
      ccms_code { "DA005" }
      meaning { "Occupation order" }
      description { "to be represented on an application for an occupation order." }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { true }
      used_delegated_functions_on { Faker::Date.between(from: 10.days.ago, to: 2.days.ago) }
      used_delegated_functions_reported_on { Time.zone.today }
      name { "occupation_order" }
      matter_type { "Domestic Abuse" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "MINJN" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :da006 do
      lead_proceeding { false }
      ccms_code { "DA006" }
      meaning { "Extend, variation or discharge - Part IV" }
      description { "to be represented on an application to extend, vary or discharge an order under Part IV Family Law Act 1996. " }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { true }
      used_delegated_functions_on { Faker::Date.between(from: 10.days.ago, to: 2.days.ago) }
      used_delegated_functions_reported_on { Time.zone.today }
      name { "extend_variation_or_discharge_part_iv" }
      matter_type { "Domestic Abuse" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "MINJN" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :da004 do
      lead_proceeding { false }
      ccms_code { "DA004" }
      meaning { "Non-molestation order" }
      description { "to be represented on an application for a non-molestation order." }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { true }
      used_delegated_functions_on { Faker::Date.between(from: 10.days.ago, to: 2.days.ago) }
      used_delegated_functions_reported_on { Time.zone.today }
      name { "nonmolestation_order" }
      matter_type { "Domestic Abuse" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "MINJN" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :se003 do
      lead_proceeding { false }
      ccms_code { "SE003" }
      meaning { "Prohibited steps order" }
      description { "to be represented on an application for a prohibited steps order." }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { nil }
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { "prohibited_steps_order_s8" }
      matter_type { "section 8 children (S8)" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "KSEC8" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :se004 do
      lead_proceeding { false }
      ccms_code { "SE004" }
      meaning { "Specific Issue Order" }
      description { "to be represented on an application for a specific issue order." }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { nil }
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { "specified_issue_order_s8" }
      matter_type { "Section 8 orders" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "KSEC8" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :se013 do
      lead_proceeding { false }
      ccms_code { "SE013" }
      meaning { "Child arrangements order (contact)" }
      description { "to be represented on an application for a child arrangements order –where the child(ren) will live" }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { nil }
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { "child_arrangements_order_contact" }
      matter_type { "Section 8 orders" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "KSEC8" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :se014 do
      lead_proceeding { false }
      ccms_code { "SE014" }
      meaning { "Child arrangements order (residence)" }
      description { "to be represented on an application for a child arrangements order –where the child(ren) will live" }
      substantive_cost_limitation { 25_000 }
      delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
      after(:create) do |proceeding, evaluator|
        create(:scope_limitation, :emergency, proceeding:) unless evaluator.no_scope_limitations
        create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
      end

      used_delegated_functions { nil }
      used_delegated_functions_on { nil }
      used_delegated_functions_reported_on { nil }
      name { "child_arrangements_order_residence" }
      matter_type { "Section 8 orders" }
      category_of_law { "Family" }
      category_law_code { "MAT" }
      ccms_matter_code { "KSEC8" }
      client_involvement_type_ccms_code { "A" }
      client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    end

    trait :opponents_application do
      after(:create) do |proceeding|
        create(:opponents_application, proceeding:)
      end
    end

    trait :final_hearing do
      after(:create) do |proceeding|
        create(:final_hearing, proceeding:)
      end
    end
  end

  trait :se013a do
    lead_proceeding { false }
    ccms_code { "SE013A" }
    meaning { "CAO contact-Appeal" }
    description { "to be represented on an application for a child arrangements order-who the child(ren) spend time with. Appeals only." }
    substantive_cost_limitation { 25_000 }
    delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "CAO contact-Appeal" }
    matter_type { "Section 8 orders" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KSEC8" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
  end

  trait :pb003 do
    lead_proceeding { false }
    ccms_code { "PB003" }
    meaning { "Child assessment order" }
    description { "to be represented on an application for a child assessment order." }
    substantive_cost_limitation { 25_000 }
    delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "child_assessment_order_sca" }
    matter_type { "special children act (SCA)" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KPBLW" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    sca_type { "core" }
    after(:create) do |proceeding, evaluator|
      create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
    end
  end

  trait :pb007 do
    lead_proceeding { false }
    ccms_code { "PB007" }
    meaning { "Contact with a child in care" }
    description { "to be represented on an application for contact with a child in care." }
    substantive_cost_limitation { 25_000 }
    delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "app_contact_child_in_care_sca" }
    matter_type { "special children act (SCA)" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KPBLW" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    sca_type { "related" }
    after(:create) do |proceeding, evaluator|
      create(:scope_limitation, :substantive, proceeding:) unless evaluator.no_scope_limitations
    end
  end

  trait :pb059 do
    lead_proceeding { false }
    ccms_code { "PB059" }
    meaning { "Supervision order" }
    description { "to be represented on an application for a supervision order" }
    substantive_cost_limitation { 25_000 }
    delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "app_for_supervision_order_sca" }
    matter_type { "special children act (SCA)" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KPBLW" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
    sca_type { "core" }
  end

  trait :pbm05 do
    lead_proceeding { false }
    ccms_code { "PBM05" }
    meaning { "Contact with a child in care" }
    description { "to be represented on an application for contact with a child in care." }
    substantive_cost_limitation { 25_000 }
    delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "contact_with_child_in_care" }
    matter_type { "public law family (PLF)" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KPBLB" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
  end

  trait :pbm16 do
    lead_proceeding { false }
    ccms_code { "PBM16" }
    meaning { "Prohibited steps order" }
    description { "to be represented on an application for a prohibited steps order." }
    substantive_cost_limitation { 25_000 }
    delegated_functions_cost_limitation { rand(1...1_000_000.0).round(2) }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "prohibited_steps_order_plf" }
    matter_type { "public law family (PLF)" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KPBLB" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
  end

  trait :pbm01a do
    lead_proceeding { false }
    ccms_code { "PBM01A" }
    meaning { "Declaration for overseas adoption - appeal" }
    description { "to be represented on an application for a declaration as to an overseas adoption.  Appeals only." }
    substantive_cost_limitation { 5000 }
    delegated_functions_cost_limitation { 2250 }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "declaration_for_overseas_adoption_appeal" }
    matter_type { "public law family (PLF)" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KPBLB" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
  end

  trait :pbm32 do
    lead_proceeding { false }
    ccms_code { "PBM32" }
    meaning { "Special guardianship order" }
    description { "to be represented on an application for a Special Guardianship Order" }
    substantive_cost_limitation { 25_000 }
    delegated_functions_cost_limitation { 2_250 }
    used_delegated_functions { nil }
    used_delegated_functions_on { nil }
    used_delegated_functions_reported_on { nil }
    name { "special_guardianship_order_plf" }
    matter_type { "public law family (PLF)" }
    category_of_law { "Family" }
    category_law_code { "MAT" }
    ccms_matter_code { "KPBLB" }
    client_involvement_type_ccms_code { "A" }
    client_involvement_type_description { "Applicant/Claimant/Petitioner" }
  end
end
