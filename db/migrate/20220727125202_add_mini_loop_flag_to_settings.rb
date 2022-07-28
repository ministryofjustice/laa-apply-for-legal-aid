class AddMiniLoopFlagToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :enable_mini_loop, :boolean, null: false, default: false
  end
end
