module Flow
  module Flows
    class ProviderStart < FlowSteps
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
          forward: :address_lookups,
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
          forward: :used_delegated_functions
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
            return :substantive_applications if application.used_delegated_functions?

            application.applicant_receives_benefit? ? :capital_introductions : :online_bankings
          end
        },
        substantive_applications: {
          path: ->(application) { urls.providers_legal_aid_application_substantive_application_path(application) },
          forward: ->(application) do
            return :providers_home unless application.substantive_application?

            application.applicant_receives_benefit? ? :capital_introductions : :online_bankings
          end
        },
        online_bankings: {
          path: ->(application) { urls.providers_legal_aid_application_online_banking_path(application) },
          forward: ->(application) { application.applicant.uses_online_banking? ? :email_addresses : :place_holder_ccms }
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
        place_holder_ccms: {
          path: '[PLACEHOLDER] Page directing provider to use CCMS'
        }
      }.freeze
    end
  end
end
