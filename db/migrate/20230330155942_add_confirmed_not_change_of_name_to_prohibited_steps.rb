class AddConfirmedNotChangeOfNameToProhibitedSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :prohibited_steps, :confirmed_not_change_of_name, :boolean, null: true
  end
end
