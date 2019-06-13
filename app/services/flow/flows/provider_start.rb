module Flow
  module Flows
    class ProviderStart < FlowSteps
      STEPS = {
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
          forward: ->(application) { application.benefit_check_result.positive? ? :capital_introductions : :used_delegated_functions }
        },
        used_delegated_functions: {
          path: ->(application) { urls.providers_legal_aid_application_used_delegated_functions_path(application) },
          forward: ->(application) { application.used_delegated_functions? ? :substantive_applications : :online_bankings }
        },
        substantive_applications: {
          path: ->(application) { urls.providers_legal_aid_application_substantive_application_path(application) }
        },
        online_bankings: {
          path: ->(application) { urls.providers_legal_aid_application_online_banking_path(application) },
          forward: ->(application) { application.applicant.uses_online_banking? ? :about_the_financial_assessments : :place_holder_ccms }
        },
        about_the_financial_assessments: {
          path: ->(application) { urls.providers_legal_aid_application_about_the_financial_assessment_path(application) },
          forward: :application_confirmations
        },
        email_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_email_address_path(application) },
          forward: :about_the_financial_assessments
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
