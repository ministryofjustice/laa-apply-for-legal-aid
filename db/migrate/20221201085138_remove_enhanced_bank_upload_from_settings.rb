class RemoveEnhancedBankUploadFromSettings < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :settings, :enhanced_bank_upload, :boolean, null: false, default: false
    end
  end
end
