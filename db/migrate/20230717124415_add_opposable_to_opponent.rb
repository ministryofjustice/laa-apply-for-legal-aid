class AddOpposableToOpponent < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :opponents, bulk: true do |t|
        t.string :opposable_type, true: false
        t.uuid :opposable_id, null: true, type: :uuid

        t.index [:opposable_id, :opposable_type], unique: true
      end
    end
  end
end
