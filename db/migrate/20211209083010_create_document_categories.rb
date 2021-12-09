class CreateDocumentCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :document_categories, id: :uuid do |t|
      t.string :name, null: false
      t.boolean :submit_to_ccms, null: false, default: false
      t.string :ccms_document_type
      t.boolean :display_on_evidence_upload, null: false, default: false
      t.boolean :mandatory, null: false, default: false

      t.timestamps
    end
  end
end
