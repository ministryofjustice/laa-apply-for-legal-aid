class CreatePartners < ActiveRecord::Migration[7.0]
  def change
    create_table :partners, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.boolean :has_national_insurance_number
      t.string :national_insurance_number
      t.belongs_to :legal_aid_application, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
