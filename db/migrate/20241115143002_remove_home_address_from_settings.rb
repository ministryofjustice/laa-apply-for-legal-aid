class RemoveHomeAddressFromSettings < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :settings, :home_address, :boolean }
  end
end
