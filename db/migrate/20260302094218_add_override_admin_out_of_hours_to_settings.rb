class AddOverrideAdminOutOfHoursToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :override_admin_out_of_hours, :boolean, null: false, default: false
  end
end
