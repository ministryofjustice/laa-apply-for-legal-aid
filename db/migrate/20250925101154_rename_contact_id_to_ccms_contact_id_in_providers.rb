class RenameContactIdToCCMSContactIdInProviders < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      rename_column :providers, :contact_id, :ccms_contact_id
    end
  end
end
