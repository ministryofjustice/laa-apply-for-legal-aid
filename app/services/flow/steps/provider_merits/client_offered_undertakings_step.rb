module Flow
  module Steps
    module ProviderMerits
      ClientOfferedUndertakingsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_client_offered_undertakings_path(application) },
        forward: ->(application) { Flow::MeritsLoop.forward_flow(application, :application) },
        check_answers: :check_merits_answers,
      )
    end
  end
end
