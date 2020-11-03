class RemoveCCMSDocumentIdFromPdfFiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :pdf_files, :ccms_document_id, :string
  end
end
