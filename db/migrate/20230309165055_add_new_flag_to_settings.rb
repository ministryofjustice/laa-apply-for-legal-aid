class AddNewFlagToSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :new_flag, :boolean, null: false, default: false
  end
end
