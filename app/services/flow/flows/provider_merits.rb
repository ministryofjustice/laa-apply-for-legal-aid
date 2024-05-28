module Flow
  module Flows
    class ProviderMerits < FlowSteps
      STEPS = {
        start_involved_children_task: {
          # This allows the statement of case flow to check for involved children while allowing a standard path
          #  to :involved_children from :has_other_involved_children that always goes to the new children page
          path: lambda do |application|
            if application.involved_children.any?
              urls.providers_legal_aid_application_has_other_involved_children_path(application)
            else
              urls.new_providers_legal_aid_application_involved_child_path(application)
            end
          end,
        },
        involved_children: {
          path: lambda do |application, params|
            involved_child_id = params.is_a?(Hash) && params.deep_symbolize_keys[:id]
            case involved_child_id
            when "new"
              partial_record = ApplicationMeritsTask::InvolvedChild.find_by(
                full_name: params.deep_symbolize_keys[:application_merits_task_involved_child][:full_name],
                legal_aid_application_id: application.id,
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
          forward: :has_other_involved_children,
        },
        has_other_involved_children: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_involved_children_path(application) },
          forward: lambda { |application, has_other_involved_child|
            if has_other_involved_child
              :involved_children
            else
              Flow::MeritsLoop.forward_flow(application, :application)
            end
          },
        },
        remove_involved_child: Steps::ProviderMerits::RemoveInvolvedChildStep,
        date_client_told_incidents: {
          path: ->(application) { urls.providers_legal_aid_application_date_client_told_incident_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        opponent_individuals: {
          path: ->(application) { urls.new_providers_legal_aid_application_opponent_individual_path(application) },
          forward: :has_other_opponents,
          check_answers: :check_merits_answers,
        },
        opponent_existing_organisations: {
          path: ->(application) { urls.providers_legal_aid_application_opponent_existing_organisations_path(application) },
          forward: :has_other_opponents,
          check_answers: :check_merits_answers,
        },
        opponent_new_organisations: Steps::ProviderMerits::OpponentNewOrganisationStep,
        start_opponent_task: {
          # This allows the task list to check for opponents and route to has_other_opponents
          # if they exist or show the new page if they do not
          path: lambda do |application|
            if application.opponents.any?
              urls.providers_legal_aid_application_has_other_opponent_path(application)
            else
              urls.providers_legal_aid_application_opponent_type_path(application)
            end
          end,
        },
        opponent_types: {
          path: ->(application) { urls.providers_legal_aid_application_opponent_type_path(application) },
          forward: lambda { |_application, is_individual|
            is_individual ? :opponent_individuals : :opponent_existing_organisations
          },
        },
        has_other_opponents: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_opponent_path(application) },
          forward: lambda { |application, has_other_opponent|
            has_other_opponent ? :opponent_types : Flow::MeritsLoop.forward_flow(application, :application)
          },
        },
        remove_opponent: Steps::ProviderMerits::RemoveOpponentStep,
        opponents_mental_capacities: {
          path: ->(application) { urls.providers_legal_aid_application_opponents_mental_capacity_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        domestic_abuse_summaries: {
          path: ->(application) { urls.providers_legal_aid_application_domestic_abuse_summary_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        statement_of_cases: {
          path: ->(application) { urls.providers_legal_aid_application_statement_of_case_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        client_denial_of_allegations: {
          path: ->(application) { urls.providers_legal_aid_application_client_denial_of_allegation_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        client_offered_undertakings: {
          path: ->(application) { urls.providers_legal_aid_application_client_offered_undertakings_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        in_scope_of_laspos: {
          path: ->(application) { urls.providers_legal_aid_application_in_scope_of_laspo_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        nature_of_urgencies: {
          path: ->(application) { urls.providers_legal_aid_application_nature_of_urgencies_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        matter_opposed_reasons: {
          path: ->(application) { urls.providers_legal_aid_application_matter_opposed_reason_path(application) },
          forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
          check_answers: :check_merits_answers,
        },
        chances_of_success: Steps::ProviderMerits::ChancesOfSuccessStep,
        success_prospects: Steps::ProviderMerits::SuccessProspectsStep,
        opponents_application: {
          path: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            urls.providers_merits_task_list_opponents_application_path(proceeding)
          end,
          forward: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          end,
          check_answers: :check_merits_answers,
        },
        attempts_to_settle: {
          path: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            urls.providers_merits_task_list_attempts_to_settle_path(proceeding)
          end,
          forward: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          end,
          check_answers: :check_merits_answers,
        },
        prohibited_steps: {
          path: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            urls.providers_merits_task_list_prohibited_steps_path(proceeding)
          end,
          forward: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          end,
          check_answers: :check_merits_answers,
        },
        linked_children: {
          path: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            urls.providers_merits_task_list_linked_children_path(proceeding)
          end,
          forward: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          end,
          check_answers: :check_merits_answers,
        },
        specific_issue: {
          path: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            urls.providers_merits_task_list_specific_issue_path(proceeding)
          end,
          forward: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          end,
          check_answers: :check_merits_answers,
        },
        vary_order: {
          path: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            urls.providers_merits_task_list_vary_order_path(proceeding)
          end,
          forward: lambda do |application|
            proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          end,
          check_answers: :check_merits_answers,
        },
        merits_task_lists: {
          path: ->(application) { urls.providers_legal_aid_application_merits_task_list_path(application) },
          forward: ->(application) { application.evidence_is_required? ? :uploaded_evidence_collections : :check_merits_answers },
        },
        uploaded_evidence_collections: {
          path: ->(application) { urls.providers_legal_aid_application_uploaded_evidence_collection_path(application) },
          forward: :check_merits_answers,
        },
        check_merits_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_merits_answers_path(application) },
          forward: :confirm_client_declarations,
        },
        confirm_client_declarations: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_client_declaration_path(application) },
          forward: :review_and_print_applications,
        },
        review_and_print_applications: {
          path: ->(application) { urls.providers_legal_aid_application_review_and_print_application_path(application) },
          forward: :end_of_applications,
        },
        end_of_applications: {
          path: ->(application) { urls.providers_legal_aid_application_end_of_application_path(application) },
          forward: :submitted_applications,
        },
        submitted_applications: {
          path: ->(application) { urls.providers_legal_aid_application_submitted_application_path(application) },
          forward: :providers_home,
        },
        merits_reports: {
          path: ->(application) { urls.providers_legal_aid_application_merits_report_path(application) },
        },
      }.freeze
    end
  end
end
