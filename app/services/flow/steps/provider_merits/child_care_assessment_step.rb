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
          Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          # TODO: AP-5533 - should goto question 4b or CYA page
          # if proceeding.child_care_assessment.assessed?
          #   :child_care_assessment_result
          # else
          #   Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          # end
        end,
        check_answers: lambda do |_application|
          :check_merits_answers
          # TODO: AP-5533 - should goto question 4b or CYA page
          # proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          # if proceeding.child_care_assessment.assessed?
          #   :child_care_assessment_result
          # else
          #   :check_merits_answers
          # end
        end,
      )
    end
  end
end
