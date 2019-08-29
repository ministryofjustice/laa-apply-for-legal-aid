module LegalAidApplications
  class PropertyValueForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :property_value, :journey

    validate :value_presence
    validates :property_value, allow_blank: true, currency: { greater_than_or_equal_to: 0.0 }

    def initialize(*args)
      super
      @journey = :citizens unless @journey == :providers
    end

    def attributes_to_clean
      [:property_value]
    end

    private

    def value_presence
      return if draft?

      errors.add(:property_value, error_message_for(:blank)) if property_value.blank?
    end

    def error_message_for(error_type)
      I18n.t("activemodel.errors.models.legal_aid_application.attributes.property_value.#{journey}.#{error_type}")
    end

    def exclude_from_model
      [:journey]
    end
  end
end
