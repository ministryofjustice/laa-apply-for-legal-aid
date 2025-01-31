class AddOptionalDocumentCategoriesToLegalAidApplication < ActiveRecord::Migration[7.2]
  def change
    add_column :legal_aid_applications, :optional_document_categories, :string, array: true, null: false, default: []
  end
end
