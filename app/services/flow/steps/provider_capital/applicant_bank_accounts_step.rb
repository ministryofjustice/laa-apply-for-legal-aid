module Flow
  module Steps
    module ProviderCapital
      ApplicantBankAccountsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_applicant_bank_account_path(application) },
        forward: ->(application) { application.applicant.has_partner_with_no_contrary_interest? ? :partner_bank_accounts : :savings_and_investments },
        check_answers: :check_capital_answers,
      )
    end
  end
end
