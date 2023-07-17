class CreateIndividualOpponents < ActiveRecord::Migration[7.0]
  def change
    create_table :individual_opponents, id: :uuid do |t|
      t.string "first_name"
      t.string "last_name"
      t.timestamps
    end
  end
end
