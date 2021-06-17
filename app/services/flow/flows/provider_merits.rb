module Flow
  module Flows
    class ProviderMerits < FlowSteps # rubocop:disable Metrics/ClassLength
      STEPS = {
        # TODO: Remove when MultiProceeding flag is removed, this is the legacy handling for starting merits
        start_chances_of_successes: {
          path: ->(application) { urls.providers_legal_aid_application_start_chances_of_success_path(application) },
          forward: :date_client_told_incidents,
          check_answers: :check_merits_answers
        },
        start_involved_children_task: {
          # This allows the statement of case flow to check for involved children while allowing a standard path
          #  to :involved_children from :has_other_involved_children that always goes to the new children page
          path: ->(application) do
            if application.involved_children.any?
              urls.providers_legal_aid_application_has_other_involved_children_path(application)
            else
              urls.new_providers_legal_aid_application_involved_child_path(application)
            end
          end
        },
        involved_children: {
          path: ->(application, params) do
            involved_child_id = params.is_a?(Hash) && params.deep_symbolize_keys[:id]
            case involved_child_id
            when 'new'
              partial_record = ApplicationMeritsTask::InvolvedChild.find_by(
                full_name: params.deep_symbolize_keys[:application_merits_task_involved_child][:full_name],
                legal_aid_application_id: application.id
              )
              if partial_record
                urls.providers_legal_aid_application_involved_child_path(application, partial_record)
              else
                urls.new_providers_legal_aid_application_involved_child_path(application)
              end
            when /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ # uuid_regex
              urls.providers_legal_aid_application_involved_child_path(application, involved_child_id)
            else
              urls.new_providers_legal_aid_application_involved_child_path(application)
            end
          end,
          forward: :has_other_involved_children
        },
        has_other_involved_children: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_involved_children_path(application) },
          forward: ->(_application, has_other_involved_child) {
            if has_other_involved_child
              :involved_children
            else
              Setting.allow_multiple_proceedings? ? :merits_task_lists : :date_client_told_incidents
            end
          }
        },
        remove_involved_child: {
          forward: ->(application) {
            if application.involved_children.count.positive?
              :has_other_involved_children
            else
              :involved_children
            end
          }
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
        statement_of_cases: {
          path: ->(application) { urls.providers_legal_aid_application_statement_of_case_path(application) },
          forward: ->(application) do
            if Setting.allow_multiple_proceedings?
              application.section_8_proceedings? ? :start_involved_children_task : :merits_task_lists
            else
              :chances_of_success
            end
          end,
          check_answers: :check_merits_answers
        },
        chances_of_success: {
          # TODO: Remove when MultiProceeding flag is removed, this is the legacy handling for starting chance_of_success
          path: ->(application) do
            apt = application.lead_application_proceeding_type
            urls.providers_merits_task_list_chances_of_success_index_path(apt)
          end,
          forward: ->(application) do
            application_proceeding_type = application.application_proceeding_types.find(application.provider_step_params['merits_task_list_id'])
            if application_proceeding_type.chances_of_success.success_likely?
              Setting.allow_multiple_proceedings? ? :merits_task_lists : :check_merits_answers
            else
              :success_prospects
            end
          end,
          check_answers: ->(application) do
            application_proceeding_type = application.application_proceeding_types.find(application.provider_step_params['merits_task_list_id'])
            application_proceeding_type.chances_of_success.success_likely? ? :check_merits_answers : :success_prospects
          end
        },
        success_prospects: {
          path: ->(application) do
            application_proceeding_type_id = application.provider_step_params['merits_task_list_id']
            application_proceeding_type = application.application_proceeding_types.find(application_proceeding_type_id)
            urls.providers_merits_task_list_success_prospects_path(application_proceeding_type)
          end,
          forward: ->(_) { Setting.allow_multiple_proceedings? ? :merits_task_lists : :check_merits_answers },
          check_answers: :check_merits_answers
        },
        attempts_to_settle: {
          forward: :merits_task_lists,
          check_answers: :check_merits_answers
        },
        linked_children: {
          path: ->(application) do
            application_proceeding_type_id = application.provider_step_params['merits_task_list_id']
            application_proceeding_type = application.application_proceeding_types.find(application_proceeding_type_id)
            urls.providers_merits_task_list_linked_children_path(application_proceeding_type)
          end,
          forward: :merits_task_lists,
          check_answers: :check_merits_answers
        },
        merits_task_lists: {
          path: ->(application) { urls.providers_legal_aid_application_merits_task_list_path(application) },
          forward: ->(application) { application.proceeding_types.size > 1 ? :gateway_evidences : :check_merits_answers }
        },
        gateway_evidences: {
          path: ->(application) { urls.providers_legal_aid_application_gateway_evidence_path(application) },
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
