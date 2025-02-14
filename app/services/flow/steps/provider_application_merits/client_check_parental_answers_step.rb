module Flow
  module Steps
    module ProviderApplicationMerits
      ClientCheckParentalAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_client_check_parental_answer_path(application) },
        forward: lambda do |application|
          Flow::MeritsLoop.forward_flow(application, :application)
        end,
      )
    end
  end
end
