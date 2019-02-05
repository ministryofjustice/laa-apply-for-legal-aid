module Flow
  module Flows
    module ProviderStart
      STEPS = {
        legal_aid_applications: {
          forward: :applicants
        },
        applicants: {
          path: ->(application, urls) { urls.providers_legal_aid_application_applicant_path(application) },
          forward: :address_lookups,
          check_answers: :check_provider_answers
        },
        address_lookups: {
          path: ->(application, urls) { urls.providers_legal_aid_application_address_lookup_path(application) },
          forward: :address_selections,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true
        },
        address_selections: {
          path: ->(application, urls) { urls.providers_legal_aid_application_address_selection_path(application) },
          forward: :proceedings_types,
          check_answers: :check_provider_answers
        },
        addresses: {
          forward: :proceedings_types,
          check_answers: :check_provider_answers
        },
        proceedings_types: {
          path: ->(application, urls) { urls.providers_legal_aid_application_proceedings_types_path(application) },
          forward: :check_provider_answers,
          check_answers: :check_provider_answers
        },
        check_provider_answers: {
          path: ->(application, urls) { urls.providers_legal_aid_application_check_provider_answers_path(application) },
          forward: :check_benefits
        },
        check_benefits: {
          path: ->(application, urls) { urls.providers_legal_aid_application_check_benefits_path(application) },
          forward: ->(application) { application.benefit_check_result.positive? ? :own_homes : :online_bankings }
        },
        online_bankings: {
          path: ->(application, urls) { urls.providers_legal_aid_application_online_banking_path(application) },
          forward: ->(application) { application.applicant.uses_online_banking? ? :about_the_financial_assessments : :place_holder_ccms }
        },
        about_the_financial_assessments: {
          path: ->(application, urls) { urls.providers_legal_aid_application_about_the_financial_assessment_path(application) },
          forward: :application_confirmations
        },
        application_confirmations: {
          path: ->(application, urls) { urls.providers_legal_aid_application_application_confirmation_path(application) }
        },
        place_holder_ccms: {
          path: '[PLACEHOLDER] Page directing provider to use CCMS'
        }
      }.freeze
    end
  end
end
