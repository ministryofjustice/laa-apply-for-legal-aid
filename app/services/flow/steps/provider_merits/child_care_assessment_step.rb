module Flow
  module Steps
    module ProviderMerits
      ChildCareAssessmentStep = Step.new(
        path: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Steps.urls.providers_merits_task_list_child_care_assessment_path(proceeding)
        end,
        forward: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])

          if proceeding.child_care_assessment.assessed?
            :child_care_assessment_results
          else
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          end
        end,
        check_answers: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])

          if proceeding.child_care_assessment.assessed?
            :child_care_assessment_results
          else
            :check_merits_answers
          end
        end,
      )
    end
  end
end
