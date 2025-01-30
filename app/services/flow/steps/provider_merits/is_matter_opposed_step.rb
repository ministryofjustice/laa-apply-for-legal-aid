module Flow
  module Steps
    module ProviderMerits
      IsMatterOpposedStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_is_matter_opposed_path(application) },
        forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
        check_answers: :check_merits_answers,
      )
    end
  end
end
