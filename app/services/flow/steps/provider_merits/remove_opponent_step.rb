module Flow
  module Steps
    module ProviderMerits
      RemoveOpponentStep = Step.new(
        path: ->(application, opponent) { Steps.urls.providers_legal_aid_application_remove_opponent_path(application, opponent) },
        forward: lambda { |application|
          application.opponents.count.positive? ? :has_other_opponents : :opponent_types
        },
      )
    end
  end
end
