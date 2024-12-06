class AddServiceMaintenanceModeToSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :settings, :service_maintenance_mode, :boolean, null: false, default: false
  end
end
