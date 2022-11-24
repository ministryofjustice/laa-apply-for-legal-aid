module Flow
  module Flows
    class ProviderStart < FlowSteps
      STEPS = {
        providers_home: {
          path: ->(_application) { urls.providers_legal_aid_applications_path },
        },
        applicants: {
          path: ->(_) { urls.new_providers_applicant_path },
          forward: :address_lookups,
        },
        applicant_details: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_details_path(application) },
          forward: lambda do |application|
            if application.applicant_details_checked?
              :has_national_insurance_numbers
            else
              :address_lookups
            end
          end,
          check_answers: :has_national_insurance_numbers,
        },
        address_lookups: {
          path: ->(application) { urls.providers_legal_aid_application_address_lookup_path(application) },
          forward: :address_selections,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true,
        },
        address_selections: {
          path: ->(application) { urls.providers_legal_aid_application_address_selection_path(application) },
          forward: :proceedings_types,
          check_answers: :check_provider_answers,
        },
        addresses: {
          path: ->(application) { urls.providers_legal_aid_application_address_path(application) },
          forward: :proceedings_types,
          check_answers: :check_provider_answers,
        },
        applicant_employed: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_employed_index_path(application) },
          forward: lambda do |application|
            next_step = application.used_delegated_functions? ? :substantive_applications : :open_banking_consents

            if application.provider.employment_permissions?
              application.employment_journey_ineligible? ? :use_ccms_employed : next_step
            else
              application.applicant_not_employed? ? next_step : :use_ccms_employed
            end
          end,
        },
        proceedings_types: {
          path: ->(application) { urls.providers_legal_aid_application_proceedings_types_path(application) },
          forward: :has_other_proceedings,
        },
        has_other_proceedings: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_proceedings_path(application) },
          forward: lambda do |application, has_other_proceeding|
            if has_other_proceeding
              :proceedings_types
            else
              Flow::ProceedingLoop.next_step(application)
            end
          end,
        },
        used_multiple_delegated_functions: {
          path: ->(application) { urls.providers_legal_aid_application_used_multiple_delegated_functions_path(application) },
          forward: lambda do |_application, delegated_functions_used_over_month_ago|
            delegated_functions_used_over_month_ago ? :confirm_multiple_delegated_functions : :limitations
          end,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true,
        },
        confirm_multiple_delegated_functions: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_multiple_delegated_functions_path(application) },
          forward: lambda do |_application, confirmed_dates|
            confirmed_dates ? :limitations : :used_multiple_delegated_functions
          end,
        },
        limitations: {
          path: ->(application) { urls.providers_legal_aid_application_limitations_path(application) },
          forward: :has_national_insurance_numbers,
        },
        has_national_insurance_numbers: {
          path: ->(application) { urls.providers_legal_aid_application_has_national_insurance_number_path(application) },
          forward: :check_provider_answers,
        },
        check_provider_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_provider_answers_path(application) },
          forward: lambda do |application, no_means_test_required|
            if no_means_test_required
              application.change_state_machine_type("NonMeansTestedStateMachine")
              :confirm_non_means_tested_applications
            else
              application.applicant.national_insurance_number? ? :check_benefits : :no_national_insurance_numbers
            end
          end,
        },
        confirm_non_means_tested_applications: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_non_means_tested_applications_path(application) },
          forward: :merits_task_lists,
        },
        no_national_insurance_numbers: {
          path: ->(application) { urls.providers_legal_aid_application_no_national_insurance_number_path(application) },
          forward: lambda do |application|
            application.change_state_machine_type("NonPassportedStateMachine")
            :applicant_employed
          end,
        },
        check_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_check_benefits_path(application) },
          forward: lambda do |application, dwp_override_non_passported|
            if application.applicant_receives_benefit?
              application.change_state_machine_type("PassportedStateMachine")
              application.used_delegated_functions? ? :substantive_applications : :capital_introductions
            else
              application.change_state_machine_type("NonPassportedStateMachine")
              dwp_override_non_passported ? :confirm_dwp_non_passported_applications : :applicant_employed
            end
          end,
        },
        substantive_applications: {
          path: ->(application) { urls.providers_legal_aid_application_substantive_application_path(application) },
          forward: lambda do |application|
            return :delegated_confirmation unless application.substantive_application?

            if application.applicant_receives_benefit?
              :capital_introductions
            else
              :open_banking_consents
            end
          end,
        },
        delegated_confirmation: {
          path: ->(application) { urls.providers_legal_aid_application_delegated_confirmation_index_path(application) },
        },
        open_banking_consents: {
          path: ->(application) { urls.providers_legal_aid_application_open_banking_consents_path(application) },
          forward: lambda do |application|
            if application.provider_received_citizen_consent?
              :open_banking_guidances
            else
              application.uploading_bank_statements? ? :bank_statements : :use_ccms
            end
          end,
        },

        open_banking_guidances: {
          path: ->(application) { urls.providers_legal_aid_application_open_banking_guidance_path(application) },
          forward: lambda do |application, client_can_use_truelayer|
            if client_can_use_truelayer
              :email_addresses
            else
              application.provider.bank_statement_upload_permissions? ? :bank_statements : :use_ccms
            end
          end,
        },
        bank_statements: {
          path: ->(application) { urls.providers_legal_aid_application_bank_statements_path(application) },
          forward: lambda do |application|
            status = HMRC::StatusAnalyzer.call(application)

            case status
            when :hmrc_multiple_employments, :no_hmrc_data
              :full_employment_details
            when :hmrc_single_employment, :unexpected_employment_data
              :employment_incomes
            when :employed_journey_not_enabled, :provider_not_enabled_for_employed_journey, :applicant_not_employed
              if application.using_enhanced_bank_upload?
                :regular_incomes
              else
                :identify_types_of_incomes
              end
            else
              raise "Unexpected hmrc status #{status.inspect}"
            end
          end,
          check_answers: :means_summaries,
        },
        email_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_email_address_path(application) },
          forward: :about_the_financial_assessments,
        },
        about_the_financial_assessments: {
          path: ->(application) { urls.providers_legal_aid_application_about_the_financial_assessment_path(application) },
          forward: :application_confirmations,
        },
        application_confirmations: {
          path: ->(application) { urls.providers_legal_aid_application_application_confirmation_path(application) },
        },
        use_ccms: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_path(application) },
        },
        delete: {
          path: ->(application) { urls.providers_legal_aid_application_delete_path(application) },
        },
        use_ccms_employed: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_employed_index_path(application) },
        },
      }.freeze
    end
  end
end
