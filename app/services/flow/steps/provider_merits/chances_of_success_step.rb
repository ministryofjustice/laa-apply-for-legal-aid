module Flow
  module Steps
    module ProviderMerits
      ChancesOfSuccessStep = Step.new(
        path: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Steps.urls.providers_merits_task_list_chances_of_success_index_path(proceeding)
        end,
        forward: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          if proceeding.chances_of_success.success_likely?
            Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
          else
            :success_prospects
          end
        end,
        check_answers: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          proceeding.chances_of_success.success_likely? ? :check_merits_answers : :success_prospects
        end,
      )
    end
  end
end
