class CreateOpponentsApplication < ActiveRecord::Migration[7.0]
  def change
    create_table :opponents_applications, id: :uuid do |t|
      t.belongs_to :proceeding, null: false, foreign_key: true, type: :uuid
      t.boolean :has_opponents_application
      t.string :reason_for_applying

      t.timestamps
    end
  end
end
