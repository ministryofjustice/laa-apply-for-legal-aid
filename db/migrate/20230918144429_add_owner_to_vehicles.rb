class AddOwnerToVehicles < ActiveRecord::Migration[7.0]
  def change
    add_column :vehicles, :owner, :string
  end
end
