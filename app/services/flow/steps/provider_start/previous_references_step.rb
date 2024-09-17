module Flow
  module Steps
    module ProviderStart
      PreviousReferencesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_previous_references_path(application) },
        forward: :correspondence_address_choices,
        check_answers: :check_provider_answers,
      )
    end
  end
end
