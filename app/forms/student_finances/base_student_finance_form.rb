module StudentFinances
  class BaseStudentFinanceForm < BaseForm
    validates :student_finance, inclusion: { in: %w[true false] }
    validates :student_finance_amount, currency: { greater_than_or_equal_to: 0 }, if: :student_finance?

  private

    def student_finance?
      student_finance.eql?("true")
    end
  end
end
