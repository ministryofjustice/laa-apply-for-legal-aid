class AddEvidenceUploadFlagToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :enable_evidence_upload, :boolean, null: false, default: false
  end
end
