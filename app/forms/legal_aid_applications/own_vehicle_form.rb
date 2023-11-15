module LegalAidApplications
  class OwnVehicleForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :own_vehicle

    validate :own_vehicle_presence

    def own_vehicle_presence
      return if draft? || own_vehicle.present?

      errors.add(:own_vehicle, I18n.t("activemodel.errors.models.legal_aid_application.attributes.own_vehicle.#{error_key('blank')}"))
    end
  end
end
