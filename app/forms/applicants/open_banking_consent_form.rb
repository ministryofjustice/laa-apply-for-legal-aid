module Applicants
  class OpenBankingConsentForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :open_banking_consent, :consent_choice_timestamp
  end
end
