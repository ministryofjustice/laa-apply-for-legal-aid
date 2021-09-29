class RemoveMultipleProceedingsFlagFromSettings < ActiveRecord::Migration[6.1]
  def change
    remove_column :settings, :allow_multiple_proceedings, :boolean, null: false, default: false
  end
end
