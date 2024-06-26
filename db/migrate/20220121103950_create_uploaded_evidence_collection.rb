class CreateUploadedEvidenceCollection < ActiveRecord::Migration[6.1]
  def change
    create_table :uploaded_evidence_collections, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.uuid :provider_uploader_id, type: :uuid, index: true, foreign_key: true
      t.timestamps
    end
  end
end
