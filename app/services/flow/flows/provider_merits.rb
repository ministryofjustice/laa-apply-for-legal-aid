module Flow
  module Flows
    module ProviderMerits
      STEPS = {
        client_received_legal_helps: {
          path: ->(application, urls) { urls.providers_legal_aid_application_client_received_legal_help_path(application) },
          forward: :proceedings_before_the_courts,
          back: :check_passported_answers
        },
        proceedings_before_the_courts: {
          path: ->(application, urls) { urls.providers_legal_aid_application_proceedings_before_the_court_path(application) },
          forward: :statement_of_cases,
          back: :client_received_legal_helps
        },
        statement_of_cases: {
          path: ->(application, urls) { urls.providers_legal_aid_application_statement_of_case_path(application) },
          forward: :estimated_legal_costs,
          back: :proceedings_before_the_courts
        },
        estimated_legal_costs: {
          path: ->(application, urls) { urls.providers_legal_aid_application_estimated_legal_costs_path(application) },
          forward: :success_prospects,
          back: :statement_of_cases
        },
        success_prospects: {
          path: ->(application, urls) { urls.providers_legal_aid_application_success_prospects_path(application) },
          forward: :merits_declarations,
          back: :estimated_legal_costs
        },
        merits_declarations: {
          path: ->(application, urls) { urls.providers_legal_aid_application_merits_declaration_path(application) },
          forward: :check_merits_answers,
          back: :success_prospects
        },
        check_merits_answers: {
          path: ->(application, urls) { urls.providers_legal_aid_application_check_merits_answers_path(application) },
          forward: :placeholder_end_merits,
          back: :merits_declarations
        },
        placeholder_end_merits: {
          path: 'End of provider-answered merits assessment questions for passported clients'
        }
      }.freeze
    end
  end
end
