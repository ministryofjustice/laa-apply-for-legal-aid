class AddEnhancedBankUploadFeatureFlagToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :enhanced_bank_upload, :boolean, null: false, default: false
  end
end
