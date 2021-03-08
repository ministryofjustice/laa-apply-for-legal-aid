class AddDWPOverrideFlagToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :override_dwp_results, :boolean, null: false, default: false
  end
end
