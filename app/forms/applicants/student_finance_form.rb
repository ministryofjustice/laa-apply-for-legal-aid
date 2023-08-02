module Applicants
  class StudentFinanceForm < BaseForm
    form_for Applicant

    attr_accessor :student_finance, :student_finance_amount

    validates :student_finance, inclusion: { in: %w[true false] }
    validates :student_finance_amount, currency: { greater_than_or_equal_to: 0 }, if: :student_finance?

  private

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.student_finance.attributes.inclusion")
    end

    def student_finance?
      student_finance.eql?("true")
    end
  end
end
