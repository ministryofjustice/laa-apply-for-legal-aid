module Applicants
  class OpenBankingConsentForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :open_banking_consent

    def open_banking_consent?
      open_banking_consent == 'true'
    end
  end
end
