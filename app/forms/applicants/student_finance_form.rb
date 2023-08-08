module Applicants
  class StudentFinanceForm < StudentFinances::BaseStudentFinanceForm
    form_for Applicant

    attr_accessor :student_finance, :student_finance_amount
  end
end
