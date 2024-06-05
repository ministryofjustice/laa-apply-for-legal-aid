module Flow
  module Steps
    module ProviderMerits
      OpponentTypesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_opponent_type_path(application) },
        forward: lambda { |_application, is_individual|
          is_individual ? :opponent_individuals : :opponent_existing_organisations
        },
      )
    end
  end
end
