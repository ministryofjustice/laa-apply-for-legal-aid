module Flow
  module Steps
    module ProviderCapital
      PartnerBankAccountsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_bank_accounts_path(application) },
        forward: :savings_and_investments,
        check_answers: :check_capital_answers,
      )
    end
  end
end
