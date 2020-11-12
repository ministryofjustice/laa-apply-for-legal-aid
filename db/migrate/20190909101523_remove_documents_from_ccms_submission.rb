class RemoveDocumentsFromCCMSSubmission < ActiveRecord::Migration[5.2]
  def change
    remove_column :ccms_submissions, :documents, :text
  end
end
