module LegalAidApplications
  class SharedOwnershipForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :shared_ownership, :journey

    validate :shared_ownership_presence

    delegate :shared_ownership?, to: :model

    def shared_ownership_presence
      return if draft? || shared_ownership.present?

      errors.add(:shared_ownership, I18n.t("activemodel.errors.models.legal_aid_application.attributes.shared_ownership.#{journey}.blank"))
    end

    def exclude_from_model
      [:journey]
    end
  end
end
