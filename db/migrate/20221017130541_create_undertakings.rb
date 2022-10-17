class CreateUndertakings < ActiveRecord::Migration[7.0]
  def change
    create_table :undertakings, id: :uuid do |t|
      t.belongs_to :legal_aid_application, null: false, foreign_key: true, type: :uuid
      t.boolean :offered
      t.string :additional_information

      t.timestamps
    end
  end
end
