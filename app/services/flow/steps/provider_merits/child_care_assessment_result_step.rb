module Flow
  module Steps
    module ProviderMerits
      ChildCareAssessmentResultStep = Step.new(
        path: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Steps.urls.providers_merits_task_list_child_care_assessment_result_path(proceeding)
        end,
        forward: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
        end,
        check_answers: :uploaded_evidence_collections,
      )
    end
  end
end
