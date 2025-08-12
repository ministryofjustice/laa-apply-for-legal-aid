class AddMockEntraAidToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :mock_entra_id, :boolean, null: false, default: false
  end
end
