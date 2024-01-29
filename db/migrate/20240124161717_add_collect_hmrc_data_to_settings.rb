class AddCollectHMRCDataToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :collect_hmrc_data, :boolean, null: false, default: false
  end
end
