module StudentFinances
  class AnnualAmountForm < BaseForm
    form_for IrregularIncome

    attr_accessor :student_finance, :amount, :legal_aid_application

    validates :student_finance, inclusion: { in: %w[true false] }
    validates :amount, currency: { greater_than_or_equal_to: 0 }, if: :student_finance?

    def save
      return false unless valid?

      ApplicationRecord.transaction do
        legal_aid_application.update!(student_finance:)

        if student_finance?
          super
        else
          legal_aid_application.irregular_incomes.student_finance.destroy_all
        end
      end

      true
    end

  private

    def student_finance?
      student_finance == "true"
    end

    def exclude_from_model
      [:student_finance]
    end

    def attributes_to_clean
      [:amount]
    end

    def assignable_attributes
      super.merge(income_type: :student_loan, frequency: :annual)
    end
  end
end
