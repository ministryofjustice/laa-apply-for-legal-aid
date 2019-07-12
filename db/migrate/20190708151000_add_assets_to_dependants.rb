class AddAssetsToDependants < ActiveRecord::Migration[5.2]
  def change
    add_column :dependants, :has_assets_more_than_threshold, :boolean
    add_column :dependants, :assets_value, :decimal
  end
end
