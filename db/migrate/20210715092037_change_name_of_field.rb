class ChangeNameOfField < ActiveRecord::Migration[6.1]
  def change
    rename_column :opponents, :ccms_opponent_id, :ccms_opponent_number
  end
end
