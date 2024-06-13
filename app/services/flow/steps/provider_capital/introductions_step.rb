module Flow
  module Steps
    module ProviderCapital
      IntroductionsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_capital_introduction_path(application) },
        forward: :own_homes,
      )
    end
  end
end
