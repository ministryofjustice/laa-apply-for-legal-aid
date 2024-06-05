module Flow
  module Steps
    module ProviderMerits
      OpponentIndividualsStep = Step.new(
        path: ->(application) { Steps.urls.new_providers_legal_aid_application_opponent_individual_path(application) },
        forward: :has_other_opponents,
        check_answers: :check_merits_answers,
      )
    end
  end
end
