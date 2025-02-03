class RenameRequiredDocumentCategoriesToAllowedDocumentCategories < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      rename_column :legal_aid_applications, :required_document_categories, :allowed_document_categories
    end
  end
end
