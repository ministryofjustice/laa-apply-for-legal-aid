module Flow
  module Steps
    module ProviderMerits
      CheckMeritsAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_check_merits_answers_path(application) },
        forward: :confirm_client_declarations,
      )
    end
  end
end
