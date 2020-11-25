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
          forward: :respondents,
          check_answers: :check_merits_answers
        },
        respondents: {
          path: ->(application) { urls.providers_legal_aid_application_respondent_path(application) },
          forward: :statement_of_cases,
          check_answers: :check_merits_answers
        },
        proceedings_before_the_courts: {
          path: ->(application) { urls.providers_legal_aid_application_proceedings_before_the_court_path(application) },
          forward: :statement_of_cases,
          check_answers: :check_merits_answers
        },
        statement_of_cases: {
          path: ->(application) { urls.providers_legal_aid_application_statement_of_case_path(application) },
          forward: :success_likely,
          check_answers: :check_merits_answers
        },
        success_likely: {
          path: ->(application) { urls.providers_legal_aid_application_success_likely_index_path(application) },
          forward: ->(application) { application.merits_assessment.success_likely? ? :check_merits_answers : :success_prospects }
        },
        success_prospects: {
          path: ->(application) { urls.providers_legal_aid_application_success_prospects_path(application) },
          forward: :check_merits_answers
        },
        check_merits_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_merits_answers_path(application) },
          forward: :end_of_applications
        },
        end_of_applications: {
          path: ->(application) { urls.providers_legal_aid_application_end_of_application_path(application) },
          forward: :submitted_applications
        },
        submitted_applications: {
          path: ->(application) { urls.providers_legal_aid_application_submitted_application_path(application) },
          forward: :providers_home
        },
        merits_reports: {
          path: ->(application) { urls.providers_legal_aid_application_merits_report_path(application) }
        }
      }.freeze
    end
  end
end
