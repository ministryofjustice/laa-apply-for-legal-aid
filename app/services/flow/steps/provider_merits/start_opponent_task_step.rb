module Flow
  module Steps
    module ProviderMerits
      StartOpponentTaskStep = Step.new(
        # This allows the task list to check for opponents and route to has_other_opponents
        # if they exist or show the new page if they do not
        path: lambda do |application|
          if application.opponents.any?
            Steps.urls.providers_legal_aid_application_has_other_opponent_path(application)
          else
            Steps.urls.providers_legal_aid_application_opponent_type_path(application)
          end
        end,
      )
    end
  end
end
