FactoryBot.define do
  factory :legal_aid_application, aliases: [:application] do
    provider
    used_delegated_functions { false }
    used_delegated_functions_on { nil }

    trait :with_applicant do
      # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
      transient do
        with_bank_accounts { 0 }
      end
      applicant { create :applicant, with_bank_accounts: with_bank_accounts }
    end

    trait :with_applicant_and_address do
      applicant { create :applicant, :with_address }
    end

    trait :with_applicant_and_address_lookup do
      applicant { create :applicant, :with_address_lookup }
    end

    trait :provider_submitted do
      state { 'provider_submitted' }
      after :create do |application|
        create :submission, :case_ref_obtained, legal_aid_application: application
      end
    end

    trait :client_details_answers_checked do
      state { 'client_details_answers_checked' }
    end

    trait :checking_passported_answers do
      state { 'checking_passported_answers' }
    end

    trait :provider_checking_citizens_means_answers do
      state { 'provider_checking_citizens_means_answers' }
    end

    trait :means_completed do
      state { 'means_completed' }
    end

    trait :checking_merits_answers do
      state { 'checking_merits_answers' }
    end

    trait :assessment_submitted do
      state { 'assessment_submitted' }
    end

    trait :checking_client_details_answers do
      state { :checking_client_details_answers }
    end

    trait :with_proceeding_types do
      transient do
        proceeding_types_count { 1 }
      end

      after(:create) do |application, evaluator|
        proceeding_types = if evaluator.proceeding_types.empty?
                             create_list(:proceeding_type, evaluator.proceeding_types_count)
                           else
                             evaluator.proceeding_types
                           end
        application.proceeding_types = proceeding_types
        application.save
      end
    end

    # The trait :with_scope_limitations will set up:
    #
    # * one proceeding type
    # * a default substantive scope limitation for that proceeding type
    # * a default delegated functions scope limitation for that proceeding type
    # * add the default substantive scope limitation to the application
    # * add the default delegated functions scope limitation to the application (SEE NOTE BELOW)
    #
    # NOTE: The delegated function scope limitation will only be added to the application if
    # the :with_delegated_functions trait is specified BEFORE the :with_scope_limitations trait
    # when created, e.g.
    #
    #     create :legal_aid_application, :with_delegated_functions, :with_scope_limitations
    # will work.
    #
    #    create :legal_aid_application, :with_scope_limitations, :with_delegated_functions
    # will NOT work
    #
    # See factory specs at spec/factory_specs/legal_aid_application_factory_spec.rb
    #
    trait :with_scope_limitations do
      after(:create) do |application, evaluator|
        proceeding_types = if evaluator.proceeding_types.empty?
                             create_list(:proceeding_type, 1)
                           else
                             evaluator.proceeding_types
                           end
        application.proceeding_types = proceeding_types

        pt = application.proceeding_types.first
        create :scope_limitation,  :substantive_default, joined_proceeding_type: pt
        create :scope_limitation,  :delegated_functions_default, joined_proceeding_type: pt
        application.add_default_substantive_scope_limitation!
        application.add_default_delegated_functions_scope_limitation! if application.used_delegated_functions?
      end
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

    trait :with_home_shared_with_partner do
      shared_ownership { 'partner_or_ex_partner' }
    end

    trait :with_other_assets_declaration do
      other_assets_declaration { create :other_assets_declaration, :with_all_values }
    end

    trait :with_no_other_assets do
      other_assets_declaration { create :other_assets_declaration, :all_nil }
    end

    trait :with_savings_amount do
      savings_amount { create :savings_amount, :with_values }
    end

    trait :with_delegated_functions do
      transient do
        delegated_functions_date { nil }
      end
      used_delegated_functions_on { delegated_functions_date.present? ? delegated_functions_date : Date.today }
      used_delegated_functions { true }
    end

    trait :with_no_savings do
      savings_amount { create :savings_amount, :all_nil }
    end

    trait :with_no_other_assets do
      other_assets_declaration { create :other_assets_declaration, :all_nil }
    end

    trait :with_merits_assessment do
      after(:create) do |application|
        create(:merits_assessment, :with_optional_text, legal_aid_application: application)
      end
    end

    trait :with_merits_statement_of_case do
      after(:create) do |application|
        create(:statement_of_case, legal_aid_application: application)
      end
    end

    trait :with_respondent do
      respondent { create :respondent }
    end

    trait :with_restrictions do
      has_restrictions { true }
      restrictions_details { Faker::Lorem.paragraph }
    end

    trait :with_vehicle do
      transient do
        populate_vehicle { false }
      end
      own_vehicle { true }
      vehicle { populate_vehicle ? create(:vehicle, :populated) : create(:vehicle) }
    end

    trait :with_incident do
      latest_incident { create :incident }
    end

    trait :with_everything do
      with_applicant
      provider_submitted
      with_savings_amount
      with_other_assets_declaration
      with_own_home_mortgaged
      property_value { rand(1...1_000_000.0).round(2) }
      outstanding_mortgage_amount { rand(1...1_000_000.0).round(2) }
      shared_ownership { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample }
      percentage_home { rand(1...99.0).round(2) }
      with_merits_assessment
      with_merits_statement_of_case
      with_respondent
      with_restrictions
      with_incident
      with_vehicle
    end

    trait :with_negative_benefit_check_result do
      benefit_check_result { build :benefit_check_result }
    end

    trait :with_positive_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :positive }
    end

    trait :with_undetermined_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :undetermined }
    end

    trait :draft do
      draft { true }
    end

    trait :with_transaction_period do
      transaction_period_start_at { 3.months.ago.beginning_of_day }
      transaction_period_finish_at { Time.now.beginning_of_day }
    end

    trait :at_initiated do
      state { :initiated }
      provider_step { :applicants }
    end

    trait :at_checking_client_details_answers do
      with_proceeding_types
      state { :checking_client_details_answers }
      provider_step { :check_provider_answers }
    end

    trait :at_checking_passported_answers do
      with_proceeding_types
      state { :checking_passported_answers }
      provider_step { :check_passported_answers }
    end

    trait :at_client_details_answers_checked do
      with_proceeding_types
      state { :client_details_answers_checked }
      provider_step { :check_benefits }
    end

    trait :at_provider_submitted do
      with_proceeding_types
      state { :provider_submitted }
      provider_step { :check_provider_answers }
    end

    trait :at_means_completed do
      with_proceeding_types
      state { :means_completed }
      provider_step { :start_merits_assessments }
    end

    trait :at_checking_merits_answers do
      with_proceeding_types
      with_merits_assessment
      with_merits_statement_of_case
      state { :checking_merits_answers }
      provider_step { :check_merits_answers }
    end
  end
end
