class AddCCMSDocumentIdToPdfFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :pdf_files, :ccms_document_id, :text
  end
end
