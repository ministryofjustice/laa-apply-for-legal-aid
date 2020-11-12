class AddDocumentsToCCMSSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :ccms_submissions, :documents, :text, default: '{}'
  end
end
