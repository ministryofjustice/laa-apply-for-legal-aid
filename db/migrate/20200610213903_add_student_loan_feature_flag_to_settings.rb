class AddStudentLoanFeatureFlagToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :use_new_student_loan, :boolean, default: false
  end
end
