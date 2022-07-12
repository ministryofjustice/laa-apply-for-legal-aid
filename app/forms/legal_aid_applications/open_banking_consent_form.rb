module LegalAidApplications
  class OpenBankingConsentForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :provider_received_citizen_consent, :uses_online_banking

    validate :online_banking_presence

    validate :uses_online_banking_presence

  private

    def online_banking_presence
      return if draft? || provider_received_citizen_consent.present?

      errors.add(:provider_received_citizen_consent, I18n.t("activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.providers.blank"))
    end

    def uses_online_banking_presence
      return if draft? || uses_online_banking.present?

      errors.add(:uses_online_banking, I18n.t("activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.providers.blank"))
    end

    def exclude_from_model
      [:uses_online_banking]
    end
  end
end
