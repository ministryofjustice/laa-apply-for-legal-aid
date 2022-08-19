class AddLoopFlagToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :enable_loop, :boolean, null: false, default: false
  end
end
