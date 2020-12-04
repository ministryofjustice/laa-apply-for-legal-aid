module Applicants
  class OpenBankingConsentForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :open_banking_consent

    validate :open_banking_consent_presence

    private

    def open_banking_consent_presence
      return if open_banking_consent.present?

      errors.add(:open_banking_consent, I18n.t('activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.citizens.blank_html').html_safe)
    end
  end
end
