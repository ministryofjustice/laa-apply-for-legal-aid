module Flow
  module Steps
    module ProviderMerits
      OpponentExistingOrganisationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_opponent_existing_organisations_path(application) },
        forward: :has_other_opponents,
        check_answers: :check_merits_answers,
      )
    end
  end
end
