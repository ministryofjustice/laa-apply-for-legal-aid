class AddCFEComprisonRunAtToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :cfe_compare_run_at, :datetime
  end
end
