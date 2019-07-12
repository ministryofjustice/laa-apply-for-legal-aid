class CreateFirmsAndOffices < ActiveRecord::Migration[5.2]
  def change
    create_table :firms, id: :uuid do |t|
      t.timestamps
      t.string :ccms_id
      t.string :name
    end

    create_table :offices, id: :uuid do |t|
      t.timestamps
      t.string :ccms_id
      t.string :code
      t.references :firm, foreign_key: true, type: :uuid
    end

    add_reference :providers, :firm, type: :uuid, index: true, foreign_key: true
    add_reference :providers, :office, type: :uuid, index: true, foreign_key: true
    add_reference :legal_aid_applications, :office, type: :uuid, index: true, foreign_key: true
  end
end
