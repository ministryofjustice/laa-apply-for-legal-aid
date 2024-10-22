class UpdateDocumentCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :document_categories, :file_extension, :string
    add_column :document_categories, :description, :string
  end
end
