FactoryBot.define do
  factory :legal_aid_application, aliases: [:application] do
    provider

    trait :with_applicant do
      # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, with_bank_accounts:) }
    end

    trait :with_complete_applicant do
      applicant do
        build(:applicant,
              has_national_insurance_number: true,
              national_insurance_number: "JA123456D",
              applied_previously: false,
              previous_reference: nil,
              correspondence_address_choice: "home",
              addresses: [build(:address, location: "home", lookup_used: true)],
              employed: nil)
      end
    end

    trait :with_employed_applicant do
      # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, employed: true, with_bank_accounts:) }
    end

    trait :with_employed_applicant_and_extra_info do
      # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, :with_extra_employment_information, employed: true, with_bank_accounts:) }
    end

    trait :with_employed_partner_and_extra_info do
      partner { build(:partner, :with_extra_employment_information, employed: true) }
    end

    trait :with_employed_applicant_and_employed_partner do
      applicant { build(:applicant, employed: true, has_partner: true, partner_has_contrary_interest: false) }
      partner { build(:partner, employed: true) }
    end

    trait :with_self_employed_applicant do
      applicant { build(:applicant, self_employed: true) }
    end

    trait :with_applicant_in_armed_forces do
      applicant { build(:applicant, armed_forces: true) }
    end

    trait :with_single_employment do
      applicant { build(:applicant, employed: true) }
      employments { [association(:employment, owner_id: applicant.id, owner_type: applicant.class)] }
    end

    trait :with_multiple_employments do
      applicant { build(:applicant, employed: true) }
      employments { build_list(:employment, 3, owner_id: applicant.id, owner_type: applicant.class) }
    end

    trait :with_full_employment_information do
      full_employment_details { Faker::Lorem.paragraph(sentence_count: 2) }
    end

    trait :with_applicant_and_address do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, :with_address, with_bank_accounts:, same_correspondence_and_home_address: true) }
    end

    trait :with_applicant_and_no_partner do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, :with_address, with_bank_accounts:, same_correspondence_and_home_address: true, has_partner: false) }
    end

    trait :with_employed_applicant_with_student_finance do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, :with_student_finance, with_bank_accounts:, employed: true) }
    end

    trait :with_applicant_with_student_finance do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, :with_student_finance, with_bank_accounts:) }
    end

    trait :with_applicant_and_partner do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, :with_address, :with_partner, with_bank_accounts:) }
      partner { build(:partner) }
    end

    trait :with_applicant_and_partner_with_no_contrary_interest do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build(:applicant, :with_address, :with_partner_with_no_contrary_interest, with_bank_accounts:) }
      partner { build(:partner) }
    end

    trait :with_applicant_and_self_employed_partner do
      applicant { build(:applicant, :with_address, :with_partner) }
      partner { build(:partner, self_employed: true) }
    end

    trait :with_applicant_and_partner_in_armed_forces do
      applicant { build(:applicant, :with_address, :with_partner) }
      partner { build(:partner, armed_forces: true) }
    end

    trait :with_applicant_no_nino do
      applicant { build(:applicant, :with_address, :no_nino) }
    end

    trait :with_partner_no_nino do
      applicant { build(:applicant, :with_address, :with_partner) }
      partner { build(:partner, :no_nino) }
    end

    trait :with_partner_and_joint_benefit do
      applicant { build(:applicant, :with_address, :with_partner) }
      partner { build(:partner, :with_shared_benefit) }
    end

    trait :with_applicant_and_address_lookup do
      applicant { build(:applicant, :with_address_lookup) }
    end

    trait :with_under_18_applicant do
      applicant { build(:applicant, :with_address, date_of_birth: 18.years.ago + 1.day, age_for_means_test_purposes: 17) }
    end

    trait :with_under_18_applicant_and_no_partner do
      applicant { build(:applicant, :with_address, date_of_birth: 18.years.ago + 1.day, age_for_means_test_purposes: 17, has_partner: false) }
    end

    trait :with_applicant_and_employed_partner_no_nino do
      applicant { build(:applicant, :with_address, :with_partner) }
      partner { build(:partner, :no_nino, employed: true) }
    end

    trait :with_applicant_and_partner_not_employed do
      applicant { build(:applicant, :with_address, :with_partner) }
      partner { build(:partner, employed: false) }
    end

    #######################################################
    #        TRAITS TO SET STATE                          #
    #######################################################

    trait :with_non_passported_state_machine do
      before(:create) do |application|
        state_machine = FactoryBot.build(:non_passported_state_machine, legal_aid_application: application)
        application.update!(state_machine:)
      end

      non_passported
    end

    trait :with_passported_state_machine do
      before(:create) do |application|
        state_machine = FactoryBot.build(:passported_state_machine, legal_aid_application: application)
        application.update!(state_machine:)
      end

      passported
    end

    trait :with_non_means_tested_state_machine do
      state_machine factory: :non_means_tested_state_machine
    end

    trait :with_sca_state_machine do
      state_machine factory: :special_children_act_state_machine
    end

    trait :with_base_state_machine do
      state_machine factory: :base_state_machine
    end

    trait :initiated do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :initiated)
      end
    end

    trait :analysing_bank_transactions do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :analysing_bank_transactions)
      end
    end

    trait :awaiting_applicant do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :awaiting_applicant)
      end
    end

    trait :applicant_details_checked do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :applicant_details_checked)
      end
    end

    trait :applicant_entering_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :applicant_entering_means)
      end
    end

    trait :assessment_submitted do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :assessment_submitted)
      end
    end

    trait :awaiting_applicant do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :awaiting_applicant)
      end
    end

    trait :checking_applicant_details do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_applicant_details)
      end
    end

    trait :checking_citizen_answers do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_citizen_answers)
      end
    end

    trait :checking_merits_answers do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_merits_answers)
      end
    end

    trait :checking_non_passported_means do
      before(:create) do |application|
        application.change_state_machine_type("NonPassportedStateMachine")
        application.state_machine_proxy.update!(aasm_state: :checking_non_passported_means)
      end
    end

    trait :checking_means_income do
      before(:create) do |application|
        application.change_state_machine_type("NonPassportedStateMachine")
        application.state_machine_proxy.update!(aasm_state: :checking_means_income)
      end
    end

    trait :checking_passported_answers do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_passported_answers)
      end
    end

    trait :delegated_functions_used do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :delegated_functions_used)
      end
    end

    trait :entering_applicant_details do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :entering_applicant_details)
      end
    end

    trait :generating_reports do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :generating_reports)
      end
    end

    trait :overriding_dwp_result do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :overriding_dwp_result)
      end
    end

    trait :provider_assessing_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_assessing_means)
      end
    end

    trait :provider_confirming_applicant_eligibility do
      before(:create) do |application|
        application.change_state_machine_type("NonPassportedStateMachine")
        application.state_machine_proxy.update!(aasm_state: :provider_confirming_applicant_eligibility)
      end
    end

    trait :provider_entering_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_entering_means)
      end
    end

    trait :provider_entering_merits do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_entering_merits)
      end
    end

    trait :merits_parental_responsibilities do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :merits_parental_responsibilities)
      end
    end

    trait :submitting_assessment do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :submitting_assessment)
      end
    end

    trait :submission_paused do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :submission_paused)
      end
    end

    trait :use_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :unknown)
      end
    end

    trait :use_ccms_self_employed do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :applicant_self_employed)
      end
    end

    trait :use_ccms_no_banking_consent do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :no_banking_consent)
      end
    end

    trait :use_ccms_offline_accounts do
      before(:create) do |application|
        application.change_state_machine_type("NonPassportedStateMachine")
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :offline_accounts)
      end
    end

    #############################################################################

    trait :submitted_to_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: %i[assessment_submitted generating_reports submitting_assessment].sample)
      end
    end

    trait :with_merits_submitted do
      merits_submitted_at { Time.current }
      merits_submitted_by { provider }
    end

    # :with_proceedings trait
    # ============================
    # takes optional arguments
    #  - proceeding_count, (1 is assumed if absent) - will generate random proceeding.
    #  - set_lead_proceeding - may be one of:
    #    - true - the first domestic abuse proceeding will be set as the lead (default)
    #    - false - no proceeding will be set as lead
    #    - :da001 or :da004 - the specified proceeding will be set as lead
    #  - explicit_proceedings - an array of trait names from the proceeding factory
    # - delegated_functions_dates: an array of dates to add to the proceeding records - defaults to nil
    # - delegated_functions_reported_on: an array of dates to add to the proceeding records (defaults to Date.today if delegated functions date is present, otherwise nil)
    #
    # examples:
    #   - create :legal_aid_application, :with_proceedings
    #   - create :legal_aid_application, :with_proceedings, proceeding_count: 3
    #   - create :legal_aid_application, :with_proceedings, explicit_proceedings: [:da001, :se013], set_lead_proceeding: :da001
    #   - create :legal_aid_application,
    #            :with_proceedings,
    #            :with_delegated_functions_on_proceedings,
    #            proceeding_count: 2,
    #            df_options: { DA001: 35.days.ago.to_date, DA004: 36.days.ago.to_date }
    #
    # Note that the first domestic_abuse proceeding will be set as lead proceeding
    trait :with_proceedings do
      transient do
        proceeding_count { 1 }
        assign_lead_proceeding { true }
        set_lead_proceeding { true }
        explicit_proceedings { nil }
        delegated_functions_dates { nil }
        delegated_functions_reported_on { nil }
      end

      after(:create) do |application, evaluator|
        raise ":with_proceedings trait can only have a proceeding count of 1 to 4" if evaluator.proceeding_count > 4

        if evaluator.explicit_proceedings.nil?
          traits = %i[da001 da004 se014 se013]
          (0..(evaluator.proceeding_count - 1)).each do |i|
            trait = traits[i]
            lead = evaluator.set_lead_proceeding == trait || (evaluator.set_lead_proceeding == true && trait == :da001)
            create(:proceeding, trait, legal_aid_application: application, lead_proceeding: lead)
          end
        else
          evaluator.explicit_proceedings.each do |trait|
            next if Proceeding.exists?(ccms_code: trait.to_s.upcase)

            lead = evaluator.set_lead_proceeding == trait
            create(:proceeding, trait, legal_aid_application: application, lead_proceeding: lead)
          end
        end
      end
    end

    # :with_delegated_functions_on_proceedings trait
    # ========================
    # This trait must be specified after the :with_proceedings trait.
    #
    # Takes a hash as a mandatory parameter, passing
    # used_delegated_functions_on and used_delegated_functions_reported_on
    # date in an array for each proceeding ccms_code.
    # example:
    #   {
    #     DA001: [Date.yesterday, Date.current],
    #     DA004: [nil, nil],
    #     SE013: [2.days.ago, 1.day.ago]
    #   }
    #
    trait :with_delegated_functions_on_proceedings do
      transient do
        df_options { nil }
      end

      after(:create) do |application, evaluator|
        raise "Must specify an array including ccms_code and an array of two dates" if evaluator.df_options.nil?

        evaluator.df_options.each_key do |ccms_code|
          proceeding = application.proceedings.detect { |p| p.ccms_code == ccms_code.to_s }
          next if proceeding.nil? # silently ignore if df_options specify a proceeding ccms_code which isn't attached to this application

          used_delegated_functions_on, used_delegated_functions_reported_on = evaluator.df_options[ccms_code]
          proceeding.update!(used_delegated_functions: used_delegated_functions_on.present?,
                             used_delegated_functions_on:,
                             used_delegated_functions_reported_on:)
        end
      end
    end

    trait :with_multiple_proceedings_inc_section8 do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :da001)
        application.proceedings << create(:proceeding, :se014)
      end
    end

    trait :with_public_law_family_appeal do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :pbm01a)
      end
    end

    trait :with_multiple_sca_proceedings do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :pb003)
        application.proceedings << create(:proceeding, :pb059)
      end
    end

    trait :with_non_auto_grantable_sca_proceeding do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :pb007)
      end
    end

    trait :with_public_law_family_prohibited_steps_order do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :pbm16)
      end
    end

    trait :with_public_law_family_non_means_tested_proceeding do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :pbm40)
      end
    end

    trait :with_opponents_application_proceeding do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :da001, :opponents_application)
      end
    end

    trait :with_final_hearing_proceeding do
      after(:create) do |application|
        application.proceedings << create(:proceeding, :da001, :final_hearing)
      end
    end

    trait :with_dependant do
      transient do
        dependant_count { 1 }
      end

      after(:create) do |application, evaluator|
        application.dependants = evaluator.dependants.presence || create_list(:dependant, evaluator.dependant_count)
        application.save!
      end
    end

    trait :with_involved_children do
      after(:create) do |application|
        create_list(:involved_child, 3, legal_aid_application: application)
      end
    end

    trait :with_dwp_override do
      dwp_override { build(:dwp_override) }
      with_non_passported_state_machine
    end

    trait :with_property_values do
      property_value { rand(1...1_000_000.0).round(2) }
      outstanding_mortgage_amount { rand(1...1_000_000.0).round(2) }
      shared_ownership { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample }
      percentage_home { rand(1...99.0).round(2) }
    end

    trait :with_own_home_mortgaged do
      own_home { "mortgage" }
    end

    trait :with_own_home_owned_outright do
      own_home { "owned_outright" }
    end

    trait :without_own_home do
      own_home { "no" }
    end

    trait :with_home_sole_owner do
      shared_ownership { "no_sole_owner" }
    end

    trait :with_home_shared_with_partner do
      shared_ownership { "partner_or_ex_partner" }
    end

    trait :with_other_assets_declaration do
      other_assets_declaration { build(:other_assets_declaration, :with_all_values) }
    end

    trait :with_no_other_assets do
      other_assets_declaration { build(:other_assets_declaration, :all_nil) }
    end

    trait :with_policy_disregards do
      policy_disregards { build(:policy_disregards) }
    end

    trait :with_single_policy_disregard do
      policy_disregards { build(:policy_disregards, :with_selected_value) }
    end

    trait :with_populated_policy_disregards do
      policy_disregards { build(:policy_disregards, :with_selected_values) }
    end

    trait :with_mandatory_capital_disregards do
      after(:create) do |application|
        create(
          :capital_disregard,
          legal_aid_application: application,
          mandatory: true,
          name: "budgeting_advances",
          amount: 1001,
          date_received: Date.new(2024, 8, 8),
          account_name: "Halifax",
        )
      end
    end

    trait :with_discretionary_capital_disregards do
      after(:create) do |application|
        create(
          :capital_disregard,
          legal_aid_application: application,
          mandatory: false,
          name: "compensation_for_personal_harm",
          payment_reason: "life changing injuries",
          amount: 1002,
          date_received: Date.new(2024, 8, 8),
          account_name: "Halifax",
        )
      end
    end

    trait :with_savings_amount do
      savings_amount { build(:savings_amount, :with_values) }
    end

    trait :with_nil_savings_amount do
      savings_amount { build(:savings_amount, :all_nil) }
    end

    trait :with_fixed_offline_savings_accounts do
      savings_amount { build(:savings_amount, :all_zero, offline_savings_accounts: 1001) }
    end

    trait :with_fixed_offline_accounts do
      savings_amount { build(:savings_amount, :all_zero, offline_current_accounts: 1001, offline_savings_accounts: 1002) }
    end

    trait :with_substantive_application_deadline_on do
      after(:create) do |application|
        application.update!(substantive_application_deadline_on: SubstantiveApplicationDeadlineCalculator.call(application.earliest_delegated_functions_date))
      end
    end

    trait :with_no_savings do
      savings_amount { build(:savings_amount, :all_nil) }
    end

    trait :with_no_other_assets do
      other_assets_declaration { build(:other_assets_declaration, :all_nil) }
    end

    trait :with_merits_statement_of_case do
      after(:create) do |application|
        create(:statement_of_case, legal_aid_application: application)
      end
    end

    trait :with_attached_statement_of_case do
      after(:create) do |application|
        create(:statement_of_case, :with_original_file_attached, legal_aid_application: application)
      end
    end

    trait :with_attached_bank_statement do
      after(:create) do |application|
        create(:attachment, :bank_statement, legal_aid_application: application)
      end
    end

    trait :with_gateway_evidence do
      after(:create) do |application|
        create(:uploaded_evidence_collection, :with_original_file_attached, legal_aid_application: application)
      end
    end

    trait :with_opponent do
      after(:create) do |application|
        create_list(:opponent, 1, legal_aid_application: application)
      end
    end

    trait :with_parties_mental_capacity do
      parties_mental_capacity { build(:parties_mental_capacity) }
    end

    trait :with_domestic_abuse_summary do
      transient do
        police_notified { true }
        police_notified_details { "details of police notification or not" }
      end

      domestic_abuse_summary do
        build(:domestic_abuse_summary,
              police_notified: police_notified,
              police_notified_details: police_notified_details)
      end
    end

    trait :with_second_appeal do
      transient do
        second_appeal { nil }
        original_judge_level { nil }
        court_type { nil }
      end

      after(:create) do |application, evaluator|
        create(:appeal,
               legal_aid_application: application,
               second_appeal: evaluator.second_appeal,
               original_judge_level: evaluator.original_judge_level,
               court_type: evaluator.court_type)
      end
    end

    trait :with_restrictions do
      has_restrictions { true }
      restrictions_details { Faker::Lorem.paragraph }
    end

    trait :with_open_banking_consent do
      provider_received_citizen_consent { true }
    end

    trait :without_open_banking_consent do
      provider_received_citizen_consent { false }
    end

    trait :with_consent do
      open_banking_consent { true }
    end

    trait :with_vehicle do
      transient do
        populate_vehicle { false }
      end
      own_vehicle { true }
      vehicles { populate_vehicle ? build_list(:vehicle, 1, :populated) : build_list(:vehicle, 1) }
    end

    trait :with_incident do
      latest_incident { build(:incident) }
    end

    trait :with_linked_and_copied_application do
      after(:create) do |application|
        lead_application = create(:legal_aid_application, :with_applicant, :with_proceedings, application_ref: "L-123-456")
        create(:linked_application,
               confirm_link: true,
               lead_application:,
               target_application: lead_application,
               associated_application: application,
               link_type_code: "FC_LEAD")
        create(:linked_application,
               lead_application:,
               associated_application: create(:legal_aid_application, :with_applicant, :with_proceedings, application_ref: "L-456-789"),
               link_type_code: "FC_LEAD")
        application.update!(copy_case_id: lead_application.id)
      end
    end

    trait :with_everything do
      transient do
        without_vehicle { false }
      end
      populate_vehicle { true }
      with_applicant
      with_non_passported_state_machine
      applicant_entering_means
      with_savings_amount
      with_own_home_mortgaged
      property_value { rand(1...1_000_000.0).round(2) }
      outstanding_mortgage_amount { rand(1...1_000_000.0).round(2) }
      shared_ownership { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample }
      percentage_home { rand(1...99.0).round(2) }
      with_merits_statement_of_case
      with_opponent
      with_parties_mental_capacity
      with_domestic_abuse_summary
      with_restrictions
      with_incident
      with_vehicle
      with_transaction_period
      with_other_assets_declaration
      with_policy_disregards
      with_savings_amount
      with_open_banking_consent
      with_consent

      after :create do |application, evaluator|
        application.vehicles.destroy_all if evaluator.without_vehicle
      end
    end

    trait :with_everything_and_address do
      with_applicant_and_address
      with_non_passported_state_machine
      applicant_entering_means
      with_savings_amount
      with_own_home_mortgaged
      property_value { rand(1...1_000_000.0).round(2) }
      outstanding_mortgage_amount { rand(1...1_000_000.0).round(2) }
      shared_ownership { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample }
      percentage_home { rand(1...99.0).round(2) }
      with_merits_statement_of_case
      with_opponent
      with_restrictions
      with_incident
      with_vehicle
      with_transaction_period
      with_other_assets_declaration
      with_policy_disregards
      with_savings_amount
      with_open_banking_consent
      with_consent
    end

    trait :with_negative_benefit_check_result do
      benefit_check_result { build(:benefit_check_result, :negative) }
    end

    trait :with_positive_benefit_check_result do
      benefit_check_result { build(:benefit_check_result, :positive) }
    end

    trait :with_undetermined_benefit_check_result do
      benefit_check_result { build(:benefit_check_result, :undetermined) }
    end

    trait :with_skipped_benefit_check_result do
      benefit_check_result { build(:benefit_check_result, :skipped) }
    end

    trait :with_failed_benefit_check_result do
      benefit_check_result { build(:benefit_check_result, :failure) }
    end

    trait :passported do
      with_positive_benefit_check_result
    end

    trait :non_passported do
      with_negative_benefit_check_result
    end

    trait :with_attempts_to_settle do
      after(:create) do |application, _evaluator|
        application.proceedings.each { |proceeding| create(:attempts_to_settles, proceeding:) }
      end
    end

    trait :with_chances_of_success do
      transient do
        prospect { "likely" }
      end
      after(:create) do |application, evaluator|
        application.proceedings.each do |proceeding|
          proceeding.chances_of_success = create(:chances_of_success, success_prospect: evaluator.prospect, proceeding:)
        end
      end
    end

    trait :with_prohibited_steps do
      after(:create) do |application|
        proceeding = create(:proceeding, :se003)
        create(:prohibited_steps, :with_data, proceeding:)
        application.proceedings << proceeding
      end
    end

    trait :with_specific_issue do
      after(:create) do |application|
        proceeding = create(:proceeding, :se004)
        create(:specific_issue, proceeding:)
        application.proceedings << proceeding
      end
    end

    trait :with_vary_order do
      after(:create) do |application|
        proceeding = create(:proceeding, :da002)
        create(:vary_order, proceeding:)
        application.proceedings << proceeding
      end
    end

    trait :draft do
      draft { true }
    end

    trait :with_transaction_period do
      transaction_period_start_on { Date.current - 3.months }
      transaction_period_finish_on { Date.current }
    end

    trait :at_initiated do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :initiated)
      end

      provider_step { :applicants }
    end

    trait :at_entering_applicant_details do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :entering_applicant_details)
      end

      provider_step { :applicants }
    end

    trait :at_use_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :unknown)
      end

      provider_step { :use_ccms }
    end

    trait :at_checking_applicant_details do
      with_proceedings

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_applicant_details)
      end

      provider_step { :check_provider_answers }
    end

    trait :at_checking_passported_answers do
      with_proceedings

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_passported_answers)
      end

      provider_step { :check_passported_answers }
    end

    trait :at_applicant_details_checked do
      with_proceedings

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :applicant_details_checked)
      end

      provider_step { :dwp_results }
    end

    trait :at_client_completed_means do
      with_proceedings

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_citizen_answers)
      end

      provider_step { :client_completed_means }
    end

    trait :at_check_provider_answers do
      with_proceedings

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_assessing_means)
      end

      provider_step { :check_provider_answers }
    end

    trait :at_provider_entering_merits do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_entering_merits)
      end

      provider_step { :merits_task_lists }
    end

    trait :at_checking_merits_answers do
      with_proceedings
      with_merits_statement_of_case

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_merits_answers)
      end

      provider_step { :check_merits_answers }
    end

    trait :at_assessment_submitted do
      with_everything_and_address
      with_positive_benefit_check_result
      with_cfe_v3_result
      with_means_report
      with_merits_report
      with_ccms_submission

      after(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :assessment_submitted)
      end

      provider_step { :end_of_application }
    end

    trait :at_submitting_assessment do
      with_everything_and_address
      with_positive_benefit_check_result
      with_cfe_v3_result
      with_means_report
      with_merits_report
      with_ccms_submission

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :submitting_assessment)
      end

      provider_step { :end_of_application }
    end

    trait :with_maintenance_in_category do
      after :create do |application|
        maintenance_in = TransactionType.where(name: "maintenance_in").first || create(:transaction_type, :maintenance_in)

        create(
          :legal_aid_application_transaction_type,
          legal_aid_application: application,
          transaction_type: maintenance_in,
          owner_type: "Applicant",
          owner_id: application.applicant.id,
        )
      end
    end

    trait :with_maintenance_out_category do
      after :create do |application|
        maintenance_out = TransactionType.where(name: "maintenance_out").first || create(:transaction_type, :maintenance_out)

        create(
          :legal_aid_application_transaction_type,
          legal_aid_application: application,
          transaction_type: maintenance_out,
          owner_type: "Applicant",
          owner_id: application.applicant.id,
        )
      end
    end

    trait :with_bank_transactions do
      after :create do |application|
        bank_provider = create(:bank_provider, applicant: application.applicant)
        bank_account = create(:bank_account, bank_provider:)
        create(:bank_account_holder, bank_provider:)
        create(:bank_error, applicant: application.applicant)
        [90, 60, 30].each do |count|
          create(:bank_transaction,
                 :benefits,
                 :manually_chosen,
                 happened_at: count.days.ago,
                 bank_account:,
                 operation: "credit")
        end
      end
    end

    trait :with_benefits_transactions do
      after :create do |application|
        bank_provider = create(:bank_provider, applicant: application.applicant)
        bank_account = create(:bank_account, bank_provider:)
        [90, 60, 30].each do |count|
          create(:bank_transaction,
                 :benefits,
                 :manually_chosen,
                 happened_at: count.days.ago,
                 bank_account:,
                 operation: "credit")
        end
      end
    end

    trait :with_fixed_benefits_transactions do
      after :create do |application|
        bank_provider = create(:bank_provider, applicant: application.applicant)
        bank_account = create(:bank_account, bank_provider:)
        benefits = TransactionType.where(name: "benefits").first || create(:transaction_type, :benefits)

        create(
          :legal_aid_application_transaction_type,
          legal_aid_application: application,
          transaction_type: benefits,
          owner_type: "Applicant",
          owner_id: application.applicant.id,
        )

        [90, 60, 30].each do |count|
          create(:bank_transaction,
                 :manually_chosen,
                 transaction_type: benefits,
                 happened_at: count.days.ago,
                 amount: 111,
                 bank_account:,
                 operation: "credit")
        end
      end
    end

    trait :with_fixed_benefits_cash_transactions do
      after :create do |application|
        benefits = TransactionType.where(name: "benefits").first || create(:transaction_type, :benefits)

        [90, 60, 30].each do |count|
          create(:cash_transaction,
                 legal_aid_application: application,
                 transaction_type: benefits,
                 transaction_date: count.days.ago.to_date,
                 amount: 111,
                 owner_type: "Applicant",
                 owner_id: application.applicant.id,
                 month_number: count / 30)

          application.transaction_types << benefits
        end
      end
    end

    trait :with_uncategorised_credit_transactions do
      after :create do |application|
        bank_provider = create(:bank_provider, applicant: application.applicant)
        bank_account = create(:bank_account, bank_provider:)
        [90, 60, 30].each do |count|
          create(:bank_transaction, :uncategorised_credit_transaction, happened_at: count.days.ago, bank_account:, operation: "credit")
        end
      end
    end

    trait :with_uncategorised_debit_transactions do
      after :create do |application|
        bank_provider = create(:bank_provider, applicant: application.applicant)
        bank_account = create(:bank_account, bank_provider:)
        [90, 60, 30].each do |count|
          create(:bank_transaction, :uncategorised_debit_transaction, happened_at: count.days.ago, bank_account:, operation: "debit")
        end
      end
    end

    trait :with_fixed_rent_or_mortage_transactions do
      after :create do |application|
        bank_provider = create(:bank_provider, applicant: application.applicant)
        bank_account = create(:bank_account, bank_provider:)
        rent_or_mortgage = TransactionType.where(name: "rent_or_mortgage").first || create(:transaction_type, :rent_or_mortgage)

        [90, 60, 30].each do |count|
          create(:bank_transaction,
                 transaction_type: rent_or_mortgage,
                 happened_at: count.days.ago,
                 amount: 111,
                 bank_account:,
                 operation: "debit")

          create(
            :legal_aid_application_transaction_type,
            legal_aid_application: application,
            transaction_type: rent_or_mortgage,
            owner_type: "Applicant",
            owner_id: application.applicant.id,
          )
        end
      end
    end

    trait :with_fixed_rent_or_mortage_cash_transactions do
      after :create do |application|
        rent_or_mortgage = TransactionType.where(name: "rent_or_mortgage").first || create(:transaction_type, :rent_or_mortgage)

        [90, 60, 30].each do |count|
          create(:cash_transaction,
                 legal_aid_application: application,
                 transaction_type: rent_or_mortgage,
                 transaction_date: count.days.ago.to_date,
                 amount: 222,
                 owner_type: "Applicant",
                 owner_id: application.applicant.id,
                 month_number: count / 30)

          application.transaction_types << rent_or_mortgage
        end
      end
    end

    trait :with_regular_transactions do
      after(:create) do |application|
        application.transaction_types << (TransactionType.find_by(name: "maintenance_in") || create(:transaction_type, :maintenance_in))
        application.transaction_types << (TransactionType.find_by(name: "maintenance_out") || create(:transaction_type, :maintenance_out))

        create(:regular_transaction, :maintenance_in, legal_aid_application: application)
        create(:regular_transaction, :maintenance_out, legal_aid_application: application)
      end
    end

    trait :with_maintenance_in_regular_transaction do
      after(:create) do |application|
        application.transaction_types << (TransactionType.find_by(name: "maintenance_in") || create(:transaction_type, :maintenance_in))
        create(:regular_transaction, :maintenance_in, legal_aid_application: application, owner_id: application.applicant.id, owner_type: "Applicant")
      end
    end

    trait :with_partner_maintenance_in_regular_transaction do
      after(:create) do |application|
        application.transaction_types << (TransactionType.find_by(name: "maintenance_in") || create(:transaction_type, :rent_or_mortgage))
        create(:regular_transaction, :maintenance_in, legal_aid_application: application, owner_id: application.applicant.id, owner_type: "Partner")
      end
    end

    trait :with_housing_benefit_regular_transaction do
      after(:build) do |application|
        application.applicant_in_receipt_of_housing_benefit = true
      end

      after(:create) do |application|
        application.transaction_types << (TransactionType.find_by(name: "housing_benefit") || create(:transaction_type, :housing_benefit))
        create(:regular_transaction, :housing_benefit, legal_aid_application: application, amount: 1_200.00, frequency: "three_monthly", owner_id: application.applicant.id, owner_type: "Applicant")
      end
    end

    trait :with_rent_or_mortgage_regular_transaction do
      after(:create) do |application|
        application.transaction_types << (TransactionType.find_by(name: "rent_or_mortgage") || create(:transaction_type, :rent_or_mortgage))
        create(:regular_transaction, :rent_or_mortgage, legal_aid_application: application, amount: 1_600.00, frequency: "three_monthly", owner_id: application.applicant.id, owner_type: "Applicant")
      end
    end

    trait :with_partner_rent_or_mortgage_regular_transaction do
      after(:create) do |application|
        application.transaction_types << (TransactionType.find_by(name: "rent_or_mortgage") || create(:transaction_type, :rent_or_mortgage))
        create(:regular_transaction, :rent_or_mortgage, legal_aid_application: application, amount: 1_600.00, frequency: "three_monthly", owner_id: application.partner.id, owner_type: "Partner")
      end
    end

    trait :with_cfe_v1_result do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_v1_result, submission: cfe_submission)
      end
    end

    trait :with_cfe_v2_result do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_v2_result, submission: cfe_submission)
      end
    end

    trait :with_cfe_v3_result do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_v3_result, submission: cfe_submission)
      end
    end

    trait :with_cfe_v4_result do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_v4_result, submission: cfe_submission)
      end
    end

    trait :with_cfe_v5_result do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_v5_result, submission: cfe_submission)
      end
    end

    trait :with_cfe_v6_result do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_v6_result, submission: cfe_submission)
      end
    end

    trait :with_cfe_v5_result_obtained do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_v5_result, submission: cfe_submission)
        cfe_submission.update!(cfe_result: cfe_submission.result.result, aasm_state: "results_obtained")
      end
    end

    trait :with_cfe_empty_result do
      after :create do |application|
        cfe_submission = create(:cfe_submission, legal_aid_application: application)
        create(:cfe_empty_result, submission: cfe_submission)
      end
    end

    trait :with_means_report do
      with_cfe_v3_result
      after :create do |application|
        create(:attachment, :means_report, legal_aid_application: application)
      end
    end

    trait :with_bank_transaction_report do
      with_cfe_v3_result
      after :create do |application|
        create(:attachment, :bank_transaction_report, legal_aid_application: application)
      end
    end

    trait :with_merits_report do
      after :create do |application|
        create(:attachment, :merits_report, legal_aid_application: application)
      end
    end

    trait :with_plf_court_order_attached do
      after :create do |application|
        create(:attachment, :plf_court_order, legal_aid_application: application)
      end
    end

    trait :with_local_authority_assessment_attached do
      after :create do |application|
        create(:attachment, :local_authority_assessment, legal_aid_application: application)
      end
    end

    trait :with_ccms_submission do
      after :create do |application|
        create(:ccms_submission, :case_created, legal_aid_application: application)
      end
    end

    trait :with_ccms_submission_completed do
      after :create do |application|
        create(:ccms_submission, :case_created, :case_completed, legal_aid_application: application)
      end
    end

    trait :discarded do
      discarded_at { 5.minutes.ago }
    end

    trait :with_client_uploading_bank_statements do
      provider_received_citizen_consent { false }
    end
  end
end
