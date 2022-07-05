module StudentFinances
  class AnnualAmountForm < BaseForm
    form_for IrregularIncome

    attr_accessor :income_type, :frequency, :amount, :legal_aid_application_id, :student_finance

    validates :amount,
              currency: {
                greater_than_or_equal_to: 0,
                allow_blank: true,
              },
              presence: { unless: :amount_ignorable? }
    validate :student_finance_presence

    def attributes_to_clean
      [:amount]
    end

    def exclude_from_model
      [:student_finance]
    end

  private

    def student_finance_presence
      return if draft? || student_finance.present?

      errors.add(:student_finance, I18n.t("activemodel.errors.models.legal_aid_application.attributes.student_finance.blank"))
    end

    def amount_ignorable?
      draft? || student_finance != "true"
    end
  end
end
