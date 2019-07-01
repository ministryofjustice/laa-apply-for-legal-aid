class CreateOpponents < ActiveRecord::Migration[5.2]
  def change
    create_table :opponents, id: :uuid do |t|
      t.string :other_party_id
      t.string :title
      t.string :first_name
      t.string :surname
      t.date :date_of_birth
      t.string :relationship_to_client
      t.string :relationship_to_case
      t.string :opponent_type
      t.string :opp_relationship_to_client
      t.string :opp_relationship_to_case
      t.boolean :child, default: false

      t.timestamps
    end
  end
end
