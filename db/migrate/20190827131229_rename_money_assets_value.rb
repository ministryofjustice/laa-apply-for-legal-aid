class RenameMoneyAssetsValue < ActiveRecord::Migration[5.2]
  def change
    rename_column :other_assets_declarations, :money_assets_value, :inherited_assets_value
  end
end
