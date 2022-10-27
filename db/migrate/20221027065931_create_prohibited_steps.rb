class CreateProhibitedSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :prohibited_steps, id: :uuid do |t|
      t.belongs_to :proceeding, null: false, foreign_key: true, type: :uuid
      t.boolean :uk_removal
      t.string :details

      t.timestamps
    end
  end
end
