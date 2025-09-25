module Flow
  module Steps
    module ProviderMerits
      WhenContactWasMadeStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_when_contact_was_made_path(application) },
        forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
        check_answers: :check_merits_answers,
      )
    end
  end
end
