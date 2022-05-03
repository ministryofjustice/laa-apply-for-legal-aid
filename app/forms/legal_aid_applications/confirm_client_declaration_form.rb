module LegalAidApplications
  class ConfirmClientDeclarationForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :client_declaration_confirmed

    validate :confirm_client_declaration_presence

  private

    def confirm_client_declaration_presence
      return if draft? || client_declaration_confirmed.present?

      errors.add(:client_declaration_confirmed, I18n.t("activemodel.errors.models.legal_aid_application.attributes.client_declaration_confirmed.blank"))
    end
  end
end
