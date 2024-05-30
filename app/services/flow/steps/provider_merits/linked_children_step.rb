module Flow
  module Steps
    module ProviderMerits
      LinkedChildrenStep = Step.new(
        path: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Steps.urls.providers_merits_task_list_linked_children_path(proceeding)
        end,
        forward: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
        end,
        check_answers: :check_merits_answers,
      )
    end
  end
end
