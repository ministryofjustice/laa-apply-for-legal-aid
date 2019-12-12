module LegalAidApplications
  class OwnHomeForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :own_home, :journey

    validate :own_home_presence

    delegate :own_home_no?, :own_home_mortgage?, :own_home_owned_outright?, to: :model

    def own_home_presence
      return if draft? || own_home.present?

      errors.add(:own_home, I18n.t("activemodel.errors.models.legal_aid_application.attributes.own_home.#{journey}.blank"))
    end

    def exclude_from_model
      [:journey]
    end
  end
end
