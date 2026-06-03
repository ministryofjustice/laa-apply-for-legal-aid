module Flow
  module Steps
    module ProviderMerits
      InScopeOfLasposStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_in_scope_of_laspo_path(application) },
        forward: lambda { |application|
          if application.in_scope_of_laspo
            Flow::MeritsLoop.forward_flow(application, :application)
          else
            application.legal_framework_merits_task_list.mark_as_not_started!(:application, :laspo)
            :out_of_scope_of_laspo_interrupt
          end
        },
        check_answers: :check_merits_answers,
      )
    end
  end
end
