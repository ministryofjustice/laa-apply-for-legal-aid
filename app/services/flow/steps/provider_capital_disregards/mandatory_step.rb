module Flow
  module Steps
    module ProviderCapitalDisregards
      MandatoryStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_capital_disregards_mandatory_path(application) },
        forward: :capital_disregards_discretionary,
        check_answers: ->(application) { application.provider_checking_or_checked_citizens_means_answers? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
