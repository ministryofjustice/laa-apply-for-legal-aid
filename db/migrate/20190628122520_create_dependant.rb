class CreateDependant < ActiveRecord::Migration[5.2]
  def change
    create_table :dependants, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.integer :number
      t.string :name
      t.date :date_of_birth
      t.timestamps
    end
  end
end
