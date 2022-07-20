class AddV5ToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :enable_cfe_v5, :boolean, default: false
  end
end
