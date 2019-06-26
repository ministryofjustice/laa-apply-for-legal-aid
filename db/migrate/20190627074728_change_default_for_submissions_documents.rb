class ChangeDefaultForSubmissionsDocuments < ActiveRecord::Migration[5.2]
  def change
    change_column :ccms_submissions, :documents, :text, default: nil
  end
end
