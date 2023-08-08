module Partners
  class StudentFinanceForm < StudentFinances::BaseStudentFinanceForm
    form_for Partner

    attr_accessor :student_finance, :student_finance_amount
  end
end
