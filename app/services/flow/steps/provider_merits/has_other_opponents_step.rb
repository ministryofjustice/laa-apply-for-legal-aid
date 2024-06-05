module Flow
  module Steps
    module ProviderMerits
      HasOtherOpponentsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_has_other_opponent_path(application) },
        forward: lambda { |application, has_other_opponent|
          has_other_opponent ? :opponent_types : Flow::MeritsLoop.forward_flow(application, :application)
        },
      )
    end
  end
end
