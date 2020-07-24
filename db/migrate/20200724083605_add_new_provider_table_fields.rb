class AddNewProviderTableFields < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :portal_enabled, :boolean, default: true
    add_column :providers, :contact_id, :int
  end
end
