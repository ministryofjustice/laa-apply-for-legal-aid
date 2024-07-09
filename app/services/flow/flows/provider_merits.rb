module Flow
  module Flows
    class ProviderMerits < FlowSteps
      STEPS = {
        start_involved_children_task: Steps::ProviderMerits::StartInvolvedChildrenTaskStep,
        involved_children: Steps::ProviderMerits::InvolvedChildrenStep,
        has_other_involved_children: Steps::ProviderMerits::HasOtherInvolvedChildrenStep,
        remove_involved_child: Steps::ProviderMerits::RemoveInvolvedChildStep,
        date_client_told_incidents: Steps::ProviderMerits::DateClientToldIncidentsStep,
        opponent_individuals: Steps::ProviderMerits::OpponentIndividualsStep,
        opponent_existing_organisations: Steps::ProviderMerits::OpponentExistingOrganisationsStep,
        opponent_new_organisations: Steps::ProviderMerits::OpponentNewOrganisationStep,
        start_opponent_task: Steps::ProviderMerits::StartOpponentTaskStep,
        opponent_types: Steps::ProviderMerits::OpponentTypesStep,
        has_other_opponents: Steps::ProviderMerits::HasOtherOpponentsStep,
        remove_opponent: Steps::ProviderMerits::RemoveOpponentStep,
        opponents_mental_capacities: Steps::ProviderMerits::OpponentsMentalCapacitiesStep,
        domestic_abuse_summaries: Steps::ProviderMerits::DomesticAbuseSummariesStep,
        statement_of_cases: Steps::ProviderMerits::StatementOfCasesStep,
        client_denial_of_allegations: Steps::ProviderMerits::ClientDenialOfAllegationsStep,
        client_offered_undertakings: Steps::ProviderMerits::ClientOfferedUndertakingsStep,
        in_scope_of_laspos: Steps::ProviderMerits::InScopeOfLasposStep,
        nature_of_urgencies: Steps::ProviderMerits::NatureOfUrgenciesStep,
        matter_opposed_reasons: Steps::ProviderMerits::MatterOpposedReasonsStep,
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
        attempts_to_settle: Steps::ProviderMerits::AttemptsToSettleStep,
        prohibited_steps: Steps::ProviderMerits::ProhibitedStepsStep,
        linked_children: Steps::ProviderMerits::LinkedChildrenStep,
        specific_issue: Steps::ProviderMerits::SpecificIssueStep,
        vary_order: Steps::ProviderMerits::VaryOrderStep,
        merits_task_lists: Steps::ProviderMerits::MeritsTaskListsStep,
        uploaded_evidence_collections: Steps::ProviderMerits::UploadedEvidenceCollectionsStep,
        check_merits_answers: Steps::ProviderMerits::CheckMeritsAnswersStep,
        confirm_client_declarations: Steps::ProviderMerits::ConfirmClientDeclarationsStep,
        review_and_print_applications: Steps::ProviderMerits::ReviewAndPrintApplicationsStep,
        end_of_applications: Steps::ProviderMerits::EndOfApplicationsStep,
        submitted_applications: Steps::ProviderMerits::SubmittedApplicationsStep,
        merits_reports: Steps::ProviderMerits::MeritsReportsStep,
      }.freeze
    end
  end
end
