class CreateLegalFrameworkMeritsTaskList < ActiveRecord::Migration[6.1]
  def change
    create_table :legal_framework_merits_task_lists, id: :uuid do |t|
      t.references :legal_aid_application, foreign_key: true, type: :uuid, index: { name: 'idx_lfa_merits_task_lists_on_legal_aid_application_id' }
      t.text :serialized_data
      t.timestamps
    end
  end
end
