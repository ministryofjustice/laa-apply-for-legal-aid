class AddMultipleProceedingsFlagToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :allow_multiple_proceedings, :boolean, null: false, default: false
  end
end
