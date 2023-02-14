class RemoveFullLoopFromSettings < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :settings, :enable_loop, :boolean, null: false, default: false
    end
  end
end
