module LegalAidApplications
  class PropertyValueForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :property_value

    before_validation :clean_up_input
    validates(
      :property_value,
      presence: true,
      numericality: { greater_than: 0, allow_blank: true }
    )

    private

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
