class RemoveConfirmedFromSpecificIssues < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :specific_issues, :confirmed, :boolean }
  end
end
