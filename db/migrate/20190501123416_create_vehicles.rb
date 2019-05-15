class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles, id: :uuid do |t|
      t.decimal :estimated_value
      t.decimal :payment_remaining
      t.date :purchased_on
      t.boolean :used_regularly
      t.references(:legal_aid_application, foreign_key: true, type: :uuid)
      t.timestamps
    end
  end
end
