class RemoveFullNameFromInvolvedChildren < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :involved_children, :full_name, :string }
  end
end
