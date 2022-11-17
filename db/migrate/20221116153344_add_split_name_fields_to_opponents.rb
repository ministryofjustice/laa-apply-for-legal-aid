class AddSplitNameFieldsToOpponents < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :opponents, bulk: true do |t|
        t.string :first_name, null: true
        t.string :last_name, null: true
      end
    end
  end
end
