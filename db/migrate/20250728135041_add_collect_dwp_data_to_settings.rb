class AddCollectDWPDataToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :collect_dwp_data, :boolean, null: false, default: true
  end
end
