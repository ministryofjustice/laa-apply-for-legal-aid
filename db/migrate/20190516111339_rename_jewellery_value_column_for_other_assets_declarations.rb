class RenameJewelleryValueColumnForOtherAssetsDeclarations < ActiveRecord::Migration[5.2]
  def change
    rename_column :other_assets_declarations, :jewellery_value, :valuable_items_value
  end
end
