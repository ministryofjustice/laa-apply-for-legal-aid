class RenameCopyCase < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      rename_column :legal_aid_applications, :copy_case, :copied_case
      rename_column :legal_aid_applications, :copy_case_id, :copied_case_id
    end
  end
end
