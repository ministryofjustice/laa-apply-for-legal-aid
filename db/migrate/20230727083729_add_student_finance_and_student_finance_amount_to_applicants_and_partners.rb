class AddStudentFinanceAndStudentFinanceAmountToApplicantsAndPartners < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :student_finance, :boolean
    add_column :applicants, :student_finance_amount, :decimal
    add_column :partners, :student_finance, :boolean
    add_column :partners, :student_finance_amount, :decimal
  end
end
