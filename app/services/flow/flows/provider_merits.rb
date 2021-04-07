module Flow
  module Flows
    class ProviderMerits < FlowSteps
      STEPS = {

        start_chances_of_successes: {
          path: ->(application) { urls.providers_legal_aid_application_start_chances_of_success_path(application) },
          forward: :date_client_told_incidents,
          check_answers: :check_merits_answers
        },
        # the involved children section below has not yet been linked into the rest of the flow
        # until the merits task page is done
        # :nocov:
        involved_children: {
          path: ->(application) { urls.new_providers_legal_aid_application_involved_child_path(application) },
          forward: :has_other_involved_children
        },
        has_other_involved_children: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_involved_children_path(application) },
          forward: ->(_application, has_other_involved_child) {
            if has_other_involved_child
              :involved_children
            else
              :date_client_told_incidents
            end
          }
        },
        remove_involved_child: {
          path: ->(application, child) { urls.providers_legal_aid_application_remove_involved_child_path(application, child) },
          forward: ->(application) {
            if application.involved_children.count.positive?
              :has_other_involved_children
            else
              :involved_children
            end
          }
        },
        # :nocov:
        date_client_told_incidents: {
          path: ->(application) { urls.providers_legal_aid_application_date_client_told_incident_path(application) },
          forward: :opponent_names,
          check_answers: :check_merits_answers
        },
        opponent_names: {
          path: ->(application) { urls.providers_legal_aid_application_opponent_name_path(application) },
          forward: :opponents,
          check_answers: :check_merits_answers
        },
        opponents: {
          path: ->(application) { urls.providers_legal_aid_application_opponent_path(application) },
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
          forward: :chances_of_success,
          check_answers: :check_merits_answers
        },
        chances_of_success: {
          path: ->(application) { urls.providers_legal_aid_application_chances_of_success_index_path(application) },
          forward: ->(application) { application.chances_of_success.success_likely? ? :check_merits_answers : :success_prospects }
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
