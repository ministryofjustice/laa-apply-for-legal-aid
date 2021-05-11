module Flow
  module Flows
    class ProviderMerits < FlowSteps
      STEPS = {
        # TODO: Remove when MultiProceeding flag is removed, this is the legacy handling for starting chance_of_success
        start_chances_of_successes: {
          path: ->(application) { urls.providers_legal_aid_application_start_chances_of_success_path(application) },
          forward: :date_client_told_incidents,
          check_answers: :check_merits_answers
        },
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
              Setting.allow_multiple_proceedings? ? :merits_task_list : :date_client_told_incidents
            end
          }
        },
        remove_involved_child: {
          # :nocov:
          path: ->(application, child) { urls.providers_legal_aid_application_remove_involved_child_path(application, child) },
          forward: ->(application) {
            if application.involved_children.count.positive?
              :has_other_involved_children
            else
              :involved_children
            end
          }
          # :nocov:
        },
        date_client_told_incidents: {
          path: ->(application) { urls.providers_legal_aid_application_date_client_told_incident_path(application) },
          forward: :opponents,
          check_answers: :check_merits_answers
        },
        opponents: {
          path: ->(application) { urls.providers_legal_aid_application_opponent_path(application) },
          forward: :statement_of_cases,
          check_answers: :check_merits_answers
        },
        proceedings_before_the_courts: {
          # :nocov:
          path: ->(application) do
            apt = application.lead_application_proceeding_type
            urls.providers_merits_task_list_proceedings_before_the_court_path(apt)
          end,
          forward: :statement_of_cases,
          check_answers: :check_merits_answers
          # :nocov:
        },
        statement_of_cases: {
          path: ->(application) { urls.providers_legal_aid_application_statement_of_case_path(application) },
          forward: ->(_) { Setting.allow_multiple_proceedings? ? :involved_children : :chances_of_success },
          check_answers: :check_merits_answers
        },
        # chances_of_success: {
        #   path: ->(application) do
        #     apt = application.lead_application_proceeding_type
        #     urls.providers_merits_task_list_chances_of_success_index_path(apt)
        #   end,
        #   forward: ->(application) do
        #     apt = application.lead_application_proceeding_type
        #     chances_of_success = apt.chances_of_success
        #     chances_of_success.success_likely? ? :check_merits_answers : :success_prospects
        #   end
        # },
        chances_of_success: {
          path: ->(application) do
            application_proceeding_type = application.application_proceeding_types.find(application.provider_step_params['merits_task_list_id'])
            urls.providers_merits_task_list_chances_of_success_index_path(application_proceeding_type)
          end,
          forward: ->(application) do
            application_proceeding_type = application.application_proceeding_types.find(application.provider_step_params['merits_task_list_id'])
            application_proceeding_type.chances_of_success.success_likely? ? :merits_task_list : :success_prospects
          end
        },
        success_prospects: {
          path: ->(application) do
            application_proceeding_type_id = application.provider_step_params['merits_task_list_id']
            application_proceeding_type = application.application_proceeding_types.find(application_proceeding_type_id)
            urls.providers_merits_task_list_success_prospects_path(application_proceeding_type)
          end,
          forward: :check_merits_answers
        },
        attempts_to_settle: {
          forward: :merits_task_list
        },
        # involved_children: {
        #   forward: :merits_task_list
        # },
        merits_task_list: {
          path: ->(application) { urls.providers_legal_aid_application_merits_task_list_path(application) },
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
