module LegalAidApplications
  class PropertyValueForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :property_value, :mode

    before_validation :clean_up_input
    # validates(
    #   :property_value,
    #   presence: true,
    #   numericality: { greater_than: 0, allow_blank: true }
    # )

    # validates :property_value, presence: { message: 'citizen.blank' }, if: :citizen_mode?
    validate :value_presence, :value_numericality

    def initialize(*args)
      super
      @mode = :citizen unless @mode == :provider
    end

    private

    def value_presence
      errors.add(:property_value, error_message_for(:blank)) if property_value.blank?
    end

    def value_numericality
      errors.add(:property_value, error_message_for(:not_a_number)) if value_not_a_number?
    end

    def value_not_a_number?
      property_value.present? && valid_number_pattern !~ property_value.to_s
    end

    def error_message_for(error_type)
      I18n.t("activemodel.errors.models.legal_aid_application.attributes.property_value.#{mode}.#{error_type}")
    end

    def exclude_from_model
      [:mode]
    end

    def clean_up_input
      property_value.delete!(',') if property_value.is_a?(String) && valid_number_pattern =~ property_value
    end

    # Starts with a digit
    # Then perhaps any combination of digit, ',' or '_'
    # Then perhaps dot followed by up to 2 digits
    def valid_number_pattern
      /\A\d[,_\d]*(\.\d{,2})?\z/
    end
  end
end
