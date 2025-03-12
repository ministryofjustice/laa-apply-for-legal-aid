class RemoveConfirmedNotChangeOfNameFromProhibitedSteps < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :prohibited_steps, :confirmed_not_change_of_name, :boolean, null: true
    end
  end
end
