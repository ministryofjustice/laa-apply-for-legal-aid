class RemoveSubmittedAtFromChancesOfSuccess < ActiveRecord::Migration[6.1]
  def change
    remove_column :chances_of_successes, :submitted_at, :datetime
  end
end
