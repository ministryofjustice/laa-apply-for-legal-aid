module StudentFinances
  class BaseStudentFinanceForm < BaseForm
    validates :student_finance, inclusion: { in: %w[true false] }, unless: :draft?
    validates :student_finance_amount, currency: { greater_than_or_equal_to: 0 }, if: :student_finance?, unless: :draft?

    before_validation do
      attributes[:student_finance_amount] = nil unless student_finance?
    end

    def student_finance?
      student_finance.eql?("true")
    end

    def attributes_to_clean
      %i[student_finance_amount]
    end
  end
end
