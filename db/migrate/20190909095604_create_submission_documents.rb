class CreateSubmissionDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :ccms_submission_documents, id: :uuid do |t|
      t.uuid :submission_id
      t.string :document_id
      t.string :status
      t.string :document_type
      t.string :ccms_document_id
      t.timestamps
    end

    add_foreign_key :ccms_submission_documents, :ccms_submissions, column: :submission_id
  end
end
