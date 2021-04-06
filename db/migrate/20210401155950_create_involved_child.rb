class CreateInvolvedChild < ActiveRecord::Migration[6.1]
  def change
    create_table :involved_children, id: :uuid do |t|
      t.belongs_to :legal_aid_application, foreign_key: true, null: false, type: :uuid
      t.string :full_name
      t.date :date_of_birth
      t.timestamps
    end
  end
end
