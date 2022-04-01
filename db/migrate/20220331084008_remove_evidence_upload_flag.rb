class RemoveEvidenceUploadFlag < ActiveRecord::Migration[6.1]
  def change
    remove_column :settings, :enable_evidence_upload, :boolean, null: false, default: false
  end
end
