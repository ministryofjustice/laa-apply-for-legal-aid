module Flow
  module Steps
    module ProviderMerits
      InScopeOfLasposStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_in_scope_of_laspo_path(application) },
        forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
        check_answers: :check_merits_answers,
      )
    end
  end
end
