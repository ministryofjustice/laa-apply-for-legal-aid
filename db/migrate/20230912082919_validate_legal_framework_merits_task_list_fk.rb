class ValidateLegalFrameworkMeritsTaskListFk < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :legal_framework_merits_task_lists, :legal_aid_applications
  end
end
