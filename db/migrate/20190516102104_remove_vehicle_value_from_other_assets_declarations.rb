class RemoveVehicleValueFromOtherAssetsDeclarations < ActiveRecord::Migration[5.2]
  def change
    remove_column :other_assets_declarations, :vehicle_value, :decimal
  end
end
