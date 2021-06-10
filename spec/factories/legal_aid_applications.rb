FactoryBot.define do
  factory :legal_aid_application, aliases: [:application] do
    provider

    trait :with_applicant do
      # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build :applicant, with_bank_accounts: with_bank_accounts }
    end

    trait :with_applicant_and_address do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build :applicant, :with_address, with_bank_accounts: with_bank_accounts }
    end

    trait :with_applicant_and_address_lookup do
      applicant { build :applicant, :with_address_lookup }
    end

    #######################################################
    #        TRAITS TO SET STATE                          #
    #######################################################

    trait :with_non_passported_state_machine do
      before(:create) do |application|
        state_machine = FactoryBot.build(:non_passported_state_machine, legal_aid_application: application)
        application.update!(state_machine: state_machine)
      end
      non_passported
    end

    trait :with_passported_state_machine do
      before(:create) do |application|
        state_machine = FactoryBot.build(:passported_state_machine, legal_aid_application: application)
        application.update!(state_machine: state_machine)
      end
      passported
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
        application.state_machine_proxy.update!(aasm_state: :checking_non_passported_means)
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

    trait :provider_assessing_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_assessing_means)
      end
    end

    trait :provider_confirming_applicant_eligibility do
      before(:create) do |application|
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

    trait :submitting_assessment do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :submitting_assessment)
      end
    end

    trait :use_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :unknown)
      end
    end

    trait :use_ccms_employed do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :employed)
      end
    end

    trait :use_ccms_no_banking_consent do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :no_banking_consent)
      end
    end

    trait :use_ccms_offline_accounts do
      before(:create) do |application|
        application.change_state_machine_type('NonPassportedStateMachine')
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :offline_accounts)
      end
    end

    #############################################################################

    trait :with_irregular_income do
      student_finance { true }
      after(:create) do |application|
        create(:irregular_income, legal_aid_application: application)
      end
    end

    trait :submitted_to_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: %i[assessment_submitted generating_reports submitting_assessment].sample)
      end
    end

    trait :with_merits_submitted_at do
      merits_submitted_at { Time.current }
    end

    # :with_proceeding_types trait
    # ============================
    # takes optional arguments
    #  - set_lead_proceeding - (true or false - true is assumed) - will set the first domestic abuse
    #    proceeding as the lead proceeding
    #  - proceeding_types_count, (1 is assumed if absent) - will generate random proceeding types.
    #    OR
    #  - explicit_proceeding_types (an array of proceeding types to attach to the application).  The ProceedingType
    #                              records must already have default substantive and df scope limitations (i.e. if
    #                              created using FactoryBot, have been created with the :with_scope_limitations trait)
    #
    # examples:
    #   - create :legal_aid_application, :with_proceeding_types
    #   - create :legal_aid_application, :with_proceeding_types, proceeding_types_count: 3
    #   - create :legal_aid_application, :with_proceeding_types, explicit_proceeding_types: [pt1, pt2, pt3]
    #
    # creates the following records:
    # - ProceedingType
    # - Scope Limitation
    # - ProceedingTypeScopeLimitation
    # - ApplicationProceedingType
    # - ApplicationProceedingTypesScopeLimitation for default substantive scope limitation only
    #
    # use this trait, and :with_delegated functions to put df dates on the ApplicationProceedingType
    # and create an ApplicationProceedingTypesScopeLimitation record for the delegated function default
    # scope limitation
    #
    #
    trait :with_proceeding_types do
      transient do
        proceeding_types_count { 1 }
        explicit_proceeding_types { [] }
        assign_lead_proceeding { true }
      end

      after(:create) do |application, evaluator|
        if evaluator.explicit_proceeding_types.empty?
          proceeding_types = create_list :proceeding_type, evaluator.proceeding_types_count
          proceeding_types.each do |pt|
            create :scope_limitation, :substantive_default, joined_proceeding_type: pt
            create :scope_limitation, :delegated_functions_default, joined_proceeding_type: pt
          end
        else
          proceeding_types = evaluator.explicit_proceeding_types
        end

        proceeding_types.each do |pt|
          apt = create :application_proceeding_type, legal_aid_application: application, proceeding_type: pt
          apt.substantive_scope_limitation = pt.default_substantive_scope_limitation
        end

        if evaluator.assign_lead_proceeding == true
          da_pt = application.proceeding_types.detect(&:domestic_abuse?)
          raise 'At least one domestic abuse proceeding type must be added before you can use the :with_lead_proceeding_type trait' if da_pt.nil?

          application.application_proceeding_types.find_by(proceeding_type_id: da_pt.id).update!(lead_proceeding: true)
        end
        application.reload
      end
    end

    trait :with_multiple_proceeding_types_inc_section8 do
      after(:create) do |application, evaluator|
        if evaluator.proceeding_types.presence
          application.proceeding_types = evaluator.proceeding_types
        else
          application.proceeding_types << create(:proceeding_type, :with_real_data)
          application.proceeding_types << create(:proceeding_type, :as_section_8_child_residence)
        end
        lead_apt = application.application_proceeding_types.find_by(lead_proceeding: true)
        if lead_apt.nil?
          lead_apt = application.application_proceeding_types.detect { |apt| apt.proceeding_type.ccms_matter == 'Domestic Abuse' }
          lead_apt.update!(lead_proceeding: true)
        end
        pt = lead_apt.proceeding_type
        sl = create :scope_limitation, :substantive_default, joined_proceeding_type: pt
        apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
        AssignedSubstantiveScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                                   scope_limitation_id: sl.id)
        application.application_proceeding_types.each do |app_proc_type|
          create(:chances_of_success, :with_optional_text, application_proceeding_type: app_proc_type)
          create(:attempts_to_settles, application_proceeding_type: app_proc_type)
        end
      end
    end

    # this is a trait of an invalid state and should only be used to test invalid state transitions
    trait :with_only_section8_proceeding_type do
      after(:create) do |application|
        application.proceeding_types << create(:proceeding_type, :as_section_8_child_residence)
        application.application_proceeding_types.each do |app_proc_type|
          create(:chances_of_success, :with_optional_text, application_proceeding_type: app_proc_type)
          create(:attempts_to_settles, application_proceeding_type: app_proc_type)
        end
      end
    end

    # this trait will mark the first domestic abuse proceeding type for the application as the lead proceeding, unless one already exists
    # the application proceeding types must have been set up before calling this trait.  Only needed for deprecated traits, not for :with_proceeding_types
    #
    trait :with_lead_proceeding_type do
      after(:create) do |application|
        if application.application_proceeding_types.detect(&:lead_proceeding).nil?
          da_pt = application.proceeding_types.detect(&:domestic_abuse?)
          raise 'At least one domestic abuse proceeding type must be added before you can use the :with_lead_proceeding_type trait' if da_pt.nil?

          application.application_proceeding_types.find_by(proceeding_type_id: da_pt.id).update!(lead_proceeding: true)
          application.reload
        end
      end
    end

    # :with_delegated_functions trait
    # ===============================
    # sets the df date fields on the application proceeding type records, and also
    # links the default delegated functions scope limitation to the apt.
    #
    # must be used after :with_proceeding_types
    #
    # examples
    #
    # create legal_aid_application,
    #          :with_proceeding_types,
    #          :with_delegated_functions,
    #          :proceeding_types_count: 3
    #          delegated_functions_date: 2.days.ago,
    #          delegated_functions_reported_date: Date.yesterday
    #
    # create legal_aid_application,
    #          :with_proceeding_types,
    #          :with_delegated_functions,
    #          :proceeding_types_count: 2,
    #          delegated_functions_dates: [3.days.ago, Date.yesterday]
    #
    trait :with_delegated_functions do
      transient do
        delegated_functions_date { Date.current } # can be a date or an array of dates
        delegated_functions_reported_date { Date.current } # can be a date or an array of dates
      end

      after(:create) do |application, evaluator|
        used_dates = evaluator.delegated_functions_date.is_a?(Array) ? evaluator.delegated_functions_date : [evaluator.delegated_functions_date]
        reported_dates = evaluator.delegated_functions_reported_date.is_a?(Array) ? evaluator.delegated_functions_reported_date : [evaluator.delegated_functions_reported_date]
        application.application_proceeding_types.each_with_index do |apt, i|
          apt.update!(used_delegated_functions_on: used_dates[i] || Date.current,
                      used_delegated_functions_reported_on: reported_dates[i] || Date.current)
          apt.delegated_functions_scope_limitation = apt.proceeding_type.default_delegated_functions_scope_limitation
        end
      end
    end

    trait :with_dependant do
      transient do
        dependants_count { 1 }
      end

      after(:create) do |application, evaluator|
        application.dependants = evaluator.dependants.presence || create_list(:dependant, 1)
        application.save
      end
    end

    trait :with_involved_children do
      after(:create) do |application|
        3.times { create :involved_child, legal_aid_application: application }
      end
    end

    trait :with_dwp_override do
      dwp_override { build :dwp_override }
      with_non_passported_state_machine
    end

    trait :with_own_home_mortgaged do
      own_home { 'mortgage' }
    end

    trait :with_own_home_owned_outright do
      own_home { 'owned_outright' }
    end

    trait :without_own_home do
      own_home { 'no' }
    end

    trait :with_home_sole_owner do
      shared_ownership { 'no_sole_owner' }
    end

    trait :with_student_finance do
      student_finance { true }
    end

    trait :with_home_shared_with_partner do
      shared_ownership { 'partner_or_ex_partner' }
    end

    trait :with_other_assets_declaration do
      other_assets_declaration { build :other_assets_declaration, :with_all_values }
    end

    trait :with_no_other_assets do
      other_assets_declaration { build :other_assets_declaration, :all_nil }
    end

    trait :with_policy_disregards do
      policy_disregards { build :policy_disregards }
    end

    trait :with_single_policy_disregard do
      policy_disregards { build :policy_disregards, :with_selected_value }
    end

    trait :with_populated_policy_disregards do
      policy_disregards { build :policy_disregards, :with_selected_values }
    end

    trait :with_savings_amount do
      savings_amount { build :savings_amount, :with_values }
    end

    trait :with_substantive_application_deadline_on do
      after(:create) do |application|
        application.update!(substantive_application_deadline_on: SubstantiveApplicationDeadlineCalculator.call(application.earliest_delegated_functions_date))
      end
    end

    trait :with_no_savings do
      savings_amount { build :savings_amount, :all_nil }
    end

    trait :with_no_other_assets do
      other_assets_declaration { build :other_assets_declaration, :all_nil }
    end

    trait :with_merits_statement_of_case do
      after(:create) do |application|
        create(:statement_of_case, legal_aid_application: application)
      end
    end

    trait :with_opponent do
      opponent { build :opponent }
    end

    trait :with_restrictions do
      has_restrictions { true }
      restrictions_details { Faker::Lorem.paragraph }
    end

    trait :with_open_banking_consent do
      provider_received_citizen_consent { true }
    end

    trait :with_consent do
      open_banking_consent { true }
    end

    trait :with_vehicle do
      transient do
        populate_vehicle { false }
      end
      own_vehicle { true }
      vehicle { populate_vehicle ? build(:vehicle, :populated) : build(:vehicle) }
    end

    trait :with_incident do
      latest_incident { build :incident }
    end

    trait :with_everything do
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
      benefit_check_result { build :benefit_check_result }
    end

    trait :with_positive_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :positive }
    end

    trait :passported do
      with_positive_benefit_check_result
    end

    trait :with_chances_of_success do
      transient do
        prospect { 'likely' }
      end
      after(:create) do |application, evaluator|
        application.application_proceeding_types.each do |apt|
          apt.chances_of_success = create(:chances_of_success, application_proceeding_type: apt, success_prospect: evaluator.prospect)
        end
      end
    end

    trait :with_undetermined_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :undetermined }
    end

    trait :non_passported do
      with_negative_benefit_check_result
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
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_applicant_details)
      end

      provider_step { :check_provider_answers }
    end

    trait :at_checking_passported_answers do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_passported_answers)
      end

      provider_step { :check_passported_answers }
    end

    trait :at_applicant_details_checked do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :applicant_details_checked)
      end

      provider_step { :check_benefits }
    end

    trait :at_client_completed_means do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_citizen_answers)
      end

      provider_step { :client_completed_means }
    end

    trait :at_check_provider_answers do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_assessing_means)
      end

      provider_step { :check_provider_answers }
    end

    trait :at_checking_merits_answers do
      with_proceeding_types
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

    trait :with_bank_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        create :bank_account_holder, bank_provider: bank_provider
        create :bank_error, applicant: application.applicant
        [90, 60, 30].each do |count|
          create :bank_transaction,
                 :benefits,
                 happened_at: count.days.ago,
                 bank_account: bank_account,
                 operation: 'credit',
                 meta_data: { code: 'CHB', label: 'child_benefit', name: 'Child Benefit' }
        end
      end
    end

    trait :with_benefits_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        [90, 60, 30].each do |count|
          create :bank_transaction,
                 :benefits,
                 happened_at: count.days.ago,
                 bank_account: bank_account,
                 operation: 'credit',
                 meta_data: { code: 'CHB', label: 'child_benefit', name: 'Child Benefit' }
        end
      end
    end

    trait :with_uncategorised_credit_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        [90, 60, 30].each do |count|
          create :bank_transaction, :uncategorised_credit_transaction, happened_at: count.days.ago, bank_account: bank_account, operation: 'credit'
        end
      end
    end

    trait :with_uncategorised_debit_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        [90, 60, 30].each do |count|
          create :bank_transaction, :uncategorised_debit_transaction, happened_at: count.days.ago, bank_account: bank_account, operation: 'debit'
        end
      end
    end

    trait :with_cfe_v3_result do
      after :create do |application|
        cfe_submission = create :cfe_submission, legal_aid_application: application
        create :cfe_v3_result, submission: cfe_submission
      end
    end

    trait :with_cfe_v4_result do
      after :create do |application|
        cfe_submission = create :cfe_submission, legal_aid_application: application
        create :cfe_v4_result, submission: cfe_submission
      end
    end

    trait :with_means_report do
      with_cfe_v3_result
      after :create do |application|
        create :attachment, :means_report, legal_aid_application: application
      end
    end

    trait :with_bank_transaction_report do
      with_cfe_v3_result
      after :create do |application|
        create :attachment, :bank_transaction_report, legal_aid_application: application
      end
    end

    trait :with_merits_report do
      after :create do |application|
        create :attachment, :merits_report, legal_aid_application: application
      end
    end

    trait :with_ccms_submission do
      after :create do |application|
        create :ccms_submission, :case_created, legal_aid_application: application
      end
    end

    trait :with_ccms_submission_completed do
      after :create do |application|
        create :ccms_submission, :case_created, :case_completed, legal_aid_application: application
      end
    end

    trait :discarded do
      discarded_at { Time.current - 5.minutes }
    end

    #######################################################################################################
    #                                                                                                     #
    #     DEPRECATED - use :with_proceeding_types instead                                                 #
    #                                                                                                     #
    #######################################################################################################
    #
    trait :with_multiple_proceeding_types do
      after(:create) do |application, evaluator|
        if evaluator.proceeding_types.presence
          application.proceeding_types = evaluator.proceeding_types
        else
          application.proceeding_types << create(:proceeding_type, :with_real_data)
          application.proceeding_types << create(:proceeding_type, :as_occupation_order)
        end
        pt = application.find_or_create_lead_proceeding_type
        sl = create :scope_limitation, :substantive_default, joined_proceeding_type: pt
        apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
        AssignedSubstantiveScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                                   scope_limitation_id: sl.id)
      end
    end

    #######################################################################################################
    #                                                                                                     #
    #     DEPRECATED - use :with_proceeding_types instead                                                 #
    #                                                                                                     #
    #######################################################################################################
    #
    trait :with_substantive_scope_limitation do
      after(:create) do |application, _evaluator|
        if application.proceeding_types.empty?
          application.proceeding_types = create_list(:proceeding_type, 1)
          pt = application.find_or_create_lead_proceeding_type
          sl = create :scope_limitation, :substantive_default, joined_proceeding_type: pt
          apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
          AssignedSubstantiveScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                                     scope_limitation_id: sl.id)
          application.reload
        end
      end
    end

    #######################################################################################################
    #                                                                                                     #
    #     DEPRECATED - use :with_proceeding_types instead                                                 #
    #                                                                                                     #
    #######################################################################################################
    #
    trait :with_substantive_scope_limitation do
      after(:create) do |application, _evaluator|
        if application.proceeding_types.empty?
          application.proceeding_types = create_list(:proceeding_type, 1)
          pt = application.lead_proceeding_type
          sl = create :scope_limitation, :substantive_default, joined_proceeding_type: pt
          apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
          AssignedSubstantiveScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                                     scope_limitation_id: sl.id)
        end
      end
    end

    #######################################################################################################
    #                                                                                                     #
    #     DEPRECATED - use :with_proceeding_types instead                                                 #
    #                                                                                                     #
    #######################################################################################################
    #
    trait :with_proceeding_type_and_scope_limitations do
      transient do
        this_proceeding_type { nil }
        substantive_scope_limitation { nil }
        df_scope_limitation { nil }
      end
      after(:create) do |application, evaluator|
        pt1 = evaluator.this_proceeding_type
        sl1 = evaluator.substantive_scope_limitation
        sl2 = evaluator.df_scope_limitation

        # destroy any eligible scope limitations and build from scratch
        ProceedingTypeScopeLimitation.where(proceeding_type_id: pt1.id).map(&:destroy!)
        pt1.proceeding_type_scope_limitations << create(:proceeding_type_scope_limitation, :substantive_default, scope_limitation: sl1)
        pt1.proceeding_type_scope_limitations << create(:proceeding_type_scope_limitation, :delegated_functions_default, scope_limitation: sl2) if sl2.present?
        application.proceeding_types << pt1
        apt = application.application_proceeding_types.first
        apt.update!(lead_proceeding: true)
        AssignedSubstantiveScopeLimitation.create!(application_proceeding_type: apt, scope_limitation: sl1)
        AssignedDfScopeLimitation.create!(application_proceeding_type: apt, scope_limitation: sl2) if sl2.present?
      end
    end

    #######################################################################################################
    #                                                                                                     #
    #     DEPRECATED - use :with_proceeding_types, :with_delegated_functions instead                      #
    #                                                                                                     #
    #######################################################################################################
    #
    trait :with_multiple_delegated_functions do
      after(:create) do |application|
        application.application_proceeding_types.each_with_index do |type, i|
          type.used_delegated_functions_on = Time.zone.today - (i.month + 1.day)
          type.used_delegated_functions_reported_on = Time.zone.today unless i > 0
        end
      end
    end

    #######################################################################################################
    #                                                                                                     #
    #     DEPRECATED - use :with_proceeding_types instead                                                 #
    #                                                                                                     #
    #######################################################################################################
    #
    trait :with_application_proceeding_type do
      transient do
        proceeding_types_count { 1 }
      end

      after(:create) do |application, evaluator|
        application.proceeding_types = create_list(:proceeding_type, evaluator.proceeding_types_count)
        application.application_proceeding_types.each do |apt|
          create(:chances_of_success, :with_optional_text, application_proceeding_type: apt)
        end
      end
    end
  end
end
