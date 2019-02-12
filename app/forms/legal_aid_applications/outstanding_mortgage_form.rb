module LegalAidApplications
  class OutstandingMortgageForm
    include BaseForm
    form_for LegalAidApplication
    attr_accessor :outstanding_mortgage_amount

    before_validation :clean_up_input
    validates(
      :outstanding_mortgage_amount,
      presence: { unless: :draft? },
      numericality: { greater_than_or_equal_to: 0, allow_blank: true }
    )

    private

    def clean_up_input
      outstanding_mortgage_amount.delete!(',') if outstanding_mortgage_amount.is_a?(String) && valid_number_pattern =~ outstanding_mortgage_amount
    end

    # Starts with a digit
    # Then perhaps any combination of digit, ',' or '_'
    # Then perhaps dot followed by up to 2 digits
    def valid_number_pattern
      /\A\d[,_\d]*(\.\d{,2})?\z/
    end
  end
end
