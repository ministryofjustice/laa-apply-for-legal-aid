module StudentFinances
  class AnnualAmountForm
    include BaseForm

    form_for StudentFinances

    attr_accessor  :income_type, :frequency, :amount

    validates :amount,
              currency: { greater_than_or_equal_to: 0, allow_blank: true },
              presence: { unless: :draft? }
  end
end
