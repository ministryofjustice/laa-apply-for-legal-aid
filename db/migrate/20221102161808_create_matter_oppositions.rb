class CreateMatterOppositions < ActiveRecord::Migration[7.0]
  def change
    create_table :matter_oppositions, id: :uuid do |t|
      t.references :legal_aid_application, null: false, foreign_key: { on_delete: :cascade }, index: false, type: :uuid
      t.text :reason, null: false, default: ""

      t.timestamps
    end
  end
end
