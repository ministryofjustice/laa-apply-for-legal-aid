class CreateIncidents < ActiveRecord::Migration[5.2]
  def change
    create_table :incidents, id: :uuid do |t|
      t.date :occurred_on
      t.text :details
      t.references :legal_aid_application, index: true, type: :uuid

      t.timestamps
    end
  end
end
