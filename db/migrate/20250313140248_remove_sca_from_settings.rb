class RemoveSCAFromSettings < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :settings, :special_childrens_act, :boolean, null: false, default: false
    end
  end
end
