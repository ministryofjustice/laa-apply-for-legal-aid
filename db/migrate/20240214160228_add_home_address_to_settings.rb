class AddHomeAddressToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :home_address, :boolean, null: false, default: false
  end
end
