module Flow
  module Flows
    class ProviderMerits < FlowSteps
      STEPS = {
        start_merits_assessments: {
          path: ->(application) { urls.providers_legal_aid_application_start_merits_assessment_path(application) },
          forward: :date_client_told_incidents,
          check_answers: :check_merits_answers
        },
        date_client_told_incidents: {
          path: ->(application) { urls.providers_legal_aid_application_date_client_told_incident_path(application) },
          forward: :details_latest_incidents,
          check_answers: :check_merits_answers
        },
        details_latest_incidents: {
          path: ->(application) { urls.providers_legal_aid_application_details_latest_incident_path(application) },
          forward: :respondents,
          check_answers: :check_merits_answers
        },
        respondents: {
          path: ->(application) { urls.providers_legal_aid_application_respondent_path(application) },
          forward: :statement_of_cases,
          check_answers: :check_merits_answers
        },
        client_received_legal_helps: {
          # TODO: Should be removed when this page is being used.
          # :nocov:
          path: ->(application) { urls.providers_legal_aid_application_client_received_legal_help_path(application) },
          # :nocov:
          forward: :proceedings_before_the_courts,
          check_answers: :check_merits_answers
        },
        proceedings_before_the_courts: {
          path: ->(application) { urls.providers_legal_aid_application_proceedings_before_the_court_path(application) },
          forward: :statement_of_cases,
          check_answers: :check_merits_answers
        },
        statement_of_cases: {
          path: ->(application) { urls.providers_legal_aid_application_statement_of_case_path(application) },
          forward: :estimated_legal_costs,
          check_answers: :check_merits_answers
        },
        estimated_legal_costs: {
          path: ->(application) { urls.providers_legal_aid_application_estimated_legal_costs_path(application) },
          forward: :success_prospects,
          check_answers: :check_merits_answers
        },
        success_prospects: {
          path: ->(application) { urls.providers_legal_aid_application_success_prospects_path(application) },
          forward: :check_merits_answers,
          check_answers: :check_merits_answers
        },
        check_merits_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_merits_answers_path(application) },
          forward: :merits_declarations
        },
        merits_declarations: {
          path: ->(application) { urls.providers_legal_aid_application_merits_declaration_path(application) },
          forward: :placeholder_end_merits
        },
        placeholder_end_merits: {
          path: 'End of provider-answered merits assessment questions for passported clients'
        }
      }.freeze
    end
  end
end
