class RemoveEnableCFEV5FromSettings < ActiveRecord::Migration[7.0]
  def change
    remove_column :settings, :enable_cfe_v5, :boolean, default: false
  end
end
