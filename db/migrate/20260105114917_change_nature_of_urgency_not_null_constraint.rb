class ChangeNatureOfUrgencyNotNullConstraint < ActiveRecord::Migration[8.1]
  def change
    change_column_null :urgencies, :nature_of_urgency, true
  end
end
