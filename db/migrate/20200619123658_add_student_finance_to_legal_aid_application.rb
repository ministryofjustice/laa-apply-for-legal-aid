class AddStudentFinanceToLegalAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :legal_aid_applications, :student_finance, :boolean
  end
end
