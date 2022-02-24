class CreateEmployments < ActiveRecord::Migration[6.1]
  def change
    create_table :employments, id: :uuid do |t|
      t.references :legal_aid_application, foreign_key: true, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end
