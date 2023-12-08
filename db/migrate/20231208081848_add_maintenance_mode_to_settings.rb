class AddMaintenanceModeToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :maintenance_mode, :boolean, null: false, default: false
  end
end
