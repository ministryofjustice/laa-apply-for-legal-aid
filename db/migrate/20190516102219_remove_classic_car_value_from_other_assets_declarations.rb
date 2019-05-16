class RemoveClassicCarValueFromOtherAssetsDeclarations < ActiveRecord::Migration[5.2]
  def change
    remove_column :other_assets_declarations, :classic_car_value, :decimal
  end
end
