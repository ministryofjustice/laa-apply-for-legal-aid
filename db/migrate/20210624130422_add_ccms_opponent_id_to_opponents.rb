class AddCCMSOpponentIdToOpponents < ActiveRecord::Migration[6.1]
  def change
    add_column :opponents, :ccms_opponent_id, :integer
    add_column :involved_children, :ccms_opponent_id, :integer
  end
end
