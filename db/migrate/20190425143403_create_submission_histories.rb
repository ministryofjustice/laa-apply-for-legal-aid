class CreateSubmissionHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :ccms_submission_histories, id: :uuid do |t|
      t.uuid :submission_id, null: false
      t.string :from_state
      t.string :to_state
      t.boolean :success
      t.text :details
      t.timestamps
    end
    add_foreign_key :ccms_submission_histories, :ccms_submissions, column: :submission_id
    add_index :ccms_submission_histories, :submission_id
  end
end
