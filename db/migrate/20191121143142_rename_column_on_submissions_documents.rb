class RenameColumnOnSubmissionsDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :ccms_submission_documents, :document_id
    add_column :ccms_submission_documents, :attachment_id, :uuid
  end
end
