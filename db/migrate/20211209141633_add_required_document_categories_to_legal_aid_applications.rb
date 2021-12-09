class AddRequiredDocumentCategoriesToLegalAidApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :required_document_categories, :string, array: true, null: false, default: []
  end
end
