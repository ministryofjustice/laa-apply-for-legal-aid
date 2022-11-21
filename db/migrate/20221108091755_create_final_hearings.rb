class CreateFinalHearings < ActiveRecord::Migration[7.0]
  def change
    create_table :final_hearings, id: :uuid do |t|
      t.belongs_to :proceeding, null: false, foreign_key: true, type: :uuid
      t.integer :work_type
      t.boolean :listed, null: false
      t.date :date, null: true
      t.string :details, null: true

      t.timestamps
    end

    add_index :final_hearings, %i[proceeding_id work_type], unique: true, name: "proceeding_work_type_unique"
  end
end
