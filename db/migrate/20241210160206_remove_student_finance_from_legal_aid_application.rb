class RemoveStudentFinanceFromLegalAidApplication < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :legal_aid_applications, :student_finance, :boolean }
  end
end
