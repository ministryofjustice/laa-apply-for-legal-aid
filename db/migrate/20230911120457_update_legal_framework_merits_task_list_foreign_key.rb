class UpdateLegalFrameworkMeritsTaskListForeignKey < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :legal_framework_merits_task_lists, :legal_aid_applications
    add_foreign_key :legal_framework_merits_task_lists, :legal_aid_applications, on_delete: :cascade, validate: false
  end
end
