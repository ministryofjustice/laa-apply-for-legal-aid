module Flow
  module Steps
    module ProviderCapital
      OfflineAccountsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_offline_account_path(application) },
        forward: :savings_and_investments,
        check_answers: ->(application) { application.checking_non_passported_means? ? :check_capital_answers : :check_passported_answers },
      )
    end
  end
end
