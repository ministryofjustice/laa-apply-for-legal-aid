class CreateScopeLimitation < ActiveRecord::Migration[7.0]
  def change
    create_table :scope_limitations, id: :uuid do |t|
      t.belongs_to :proceeding, null: false, foreign_key: true, type: :uuid
      t.integer :scope_type
      t.string :code, null: false
      t.string :meaning, null: false
      t.string :description, null: false
      t.date :hearing_date, null: true
      t.string :limitation_note, null: true

      t.timestamps
    end
  end
end
