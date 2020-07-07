module StudentFinances
  class AnnualAmountForm
    include BaseForm

    form_for IrregularIncome

    attr_accessor :income_type, :frequency, :amount, :legal_aid_application_id

    validates :amount,
              currency: {
                greater_than_or_equal_to: 0,
                allow_blank: true
              },
              presence: { unless: :draft? }

    def attributes_to_clean
      [:amount]
    end
  end
end
