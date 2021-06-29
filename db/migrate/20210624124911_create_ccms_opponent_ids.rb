class CreateCCMSOpponentIds < ActiveRecord::Migration[6.1]
  def change
    create_table :ccms_opponent_ids, id: :uuid do |t|
      t.integer :serial_id, null: false
      t.timestamps
    end
  end
end
