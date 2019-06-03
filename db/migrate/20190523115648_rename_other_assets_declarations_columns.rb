class RenameOtherAssetsDeclarationsColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :other_assets_declarations, :jewellery_value, :valuable_items_value
    rename_column :other_assets_declarations, :timeshare_value, :timeshare_property_value
  end
end
