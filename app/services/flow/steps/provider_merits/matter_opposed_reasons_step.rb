module Flow
  module Steps
    module ProviderMerits
      MatterOpposedReasonsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_matter_opposed_reason_path(application) },
        forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
        check_answers: :check_merits_answers,
      )
    end
  end
end
