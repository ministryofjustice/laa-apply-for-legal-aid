class RemovePortalEnabledFromProvider < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :providers, :portal_enabled, :boolean }
  end
end
