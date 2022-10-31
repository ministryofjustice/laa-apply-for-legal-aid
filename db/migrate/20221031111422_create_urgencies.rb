class CreateUrgencies < ActiveRecord::Migration[7.0]
  def change
    create_table :urgencies, id: :uuid do |t|
      t.belongs_to :legal_aid_application, null: false, foreign_key: true, type: :uuid
      t.string :nature_of_urgency, null: false
      t.boolean :hearing_date_set, default: false, null: false
      t.date :hearing_date
      t.string :additional_information

      t.timestamps
    end
  end
end
