module Flow
  module Flows
    class ProviderStart < FlowSteps # rubocop:disable Metrics/ClassLength
      STEPS = {
        providers_home: {
          path: ->(_application) { urls.providers_legal_aid_applications_path }
        },
        applicants: {
          path: ->(_) { urls.new_providers_applicant_path },
          forward: :address_lookups
        },
        applicant_details: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_details_path(application) },
          forward: ->(application) do
            if application.applicant_details_checked?
              :check_provider_answers
            else
              :address_lookups
            end
          end,
          check_answers: :check_provider_answers
        },
        address_lookups: {
          path: ->(application) { urls.providers_legal_aid_application_address_lookup_path(application) },
          forward: :address_selections,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true
        },
        address_selections: {
          path: ->(application) { urls.providers_legal_aid_application_address_selection_path(application) },
          forward: :proceedings_types,
          check_answers: :check_provider_answers
        },
        addresses: {
          path: ->(application) { urls.providers_legal_aid_application_address_path(application) },
          forward: :proceedings_types,
          check_answers: :check_provider_answers
        },
        proceedings_types: {
          path: ->(application) { urls.providers_legal_aid_application_proceedings_types_path(application) },
          forward: :used_delegated_functions,
          check_answers: :check_provider_answers
        },
        used_delegated_functions: {
          path: ->(application) { urls.providers_legal_aid_application_used_delegated_functions_path(application) },
          forward: :limitations
        },
        limitations: {
          path: ->(application) { urls.providers_legal_aid_application_limitations_path(application) },
          forward: :check_provider_answers
        },
        check_provider_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_provider_answers_path(application) },
          forward: :check_benefits
        },
        check_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_check_benefits_path(application) },
          forward: ->(application) do
            next_step = :open_banking_consents
            if application.applicant_receives_benefit?
              application.change_state_machine_type('PassportedStateMachine')
            else
              application.change_state_machine_type('NonPassportedStateMachine')
              next_step = :applicant_employed
            end

            return :substantive_applications if application.used_delegated_functions? && application.passported?

            application.applicant_receives_benefit? ? :capital_introductions : next_step
          end
        },
        substantive_applications: {
          path: ->(application) { urls.providers_legal_aid_application_substantive_application_path(application) },
          forward: ->(application) do
            return :delegated_confirmation unless application.substantive_application?

            application.applicant_receives_benefit? ? :capital_introductions : :non_passported_client_instructions
          end
        },
        delegated_confirmation: {
          path: ->(application) { urls.providers_legal_aid_application_delegated_confirmation_index_path(application) }
        },
        applicant_employed: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_employed_index_path(application) },
          forward: ->(application) do
            application.applicant_employed? ? :use_ccms_employed : :open_banking_consents
          end
        },
        open_banking_consents: {
          path: ->(application) { urls.providers_legal_aid_application_open_banking_consents_path(application) },
          forward: ->(application) do
            next_step = :non_passported_client_instructions
            next_step = :substantive_applications if application.applicant_employed? == false && application.used_delegated_functions?

            application.provider_received_citizen_consent? ? next_step : :use_ccms
          end
        },
        email_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_email_address_path(application) },
          forward: :about_the_financial_assessments
        },
        about_the_financial_assessments: {
          path: ->(application) { urls.providers_legal_aid_application_about_the_financial_assessment_path(application) },
          forward: :application_confirmations
        },
        application_confirmations: {
          path: ->(application) { urls.providers_legal_aid_application_application_confirmation_path(application) }
        },
        use_ccms: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_path(application) }
        },
        delete: {
          path: ->(application) { urls.providers_legal_aid_application_delete_path(application) }
        },
        use_ccms_employed: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_employed_index_path(application) }
        },
        non_passported_client_instructions: {
          path: ->(application) { urls.providers_legal_aid_application_non_passported_client_instructions_path(application) },
          forward: :email_addresses
        }
      }.freeze
    end
  end
end
