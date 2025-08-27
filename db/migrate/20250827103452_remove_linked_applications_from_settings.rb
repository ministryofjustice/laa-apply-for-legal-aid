class RemoveLinkedApplicationsFromSettings < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :settings, :linked_applications, :boolean, null: false, default: false
    end
  end
end
