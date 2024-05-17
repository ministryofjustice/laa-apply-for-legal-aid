class AddScaToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :special_childrens_act, :boolean, null: false, default: false
  end
end
