module LegalAidApplications
  class OpenBankingConsentForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :provider_received_citizen_consent

    validate :consent_presence

    private

    def consent_presence
      return if draft? || provider_received_citizen_consent.present?

      errors.add(:provider_received_citizen_consent, I18n.t('activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.providers.blank'))
    end
  end
end
