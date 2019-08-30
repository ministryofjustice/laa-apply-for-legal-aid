module LegalAidApplications
  class OwnVehicleForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :own_vehicle, :journey

    validate :own_vehicle_presence

    def own_vehicle_presence
      return if draft? || own_vehicle.present?

      errors.add(:own_vehicle, I18n.t("activemodel.errors.models.legal_aid_application.attributes.own_vehicle.#{journey}.blank"))
    end

    def exclude_from_model
      [:journey]
    end
  end
end
