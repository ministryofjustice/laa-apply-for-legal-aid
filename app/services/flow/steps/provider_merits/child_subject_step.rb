module Flow
  module Steps
    module ProviderMerits
      ChildSubjectStep = Step.new(
        path: lambda do |application|
          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Steps.urls.providers_merits_task_list_is_client_child_subject_path(proceeding)
        end,
        forward: lambda do |application, options|
          return :check_who_client_is if options[:reshow_check_client].eql?(true)

          proceeding = application.proceedings.find(application.provider_step_params["merits_task_list_id"])
          Flow::MeritsLoop.forward_flow(application, proceeding.ccms_code.to_sym)
        end,
        check_answers: :check_merits_answers,
      )
    end
  end
end
