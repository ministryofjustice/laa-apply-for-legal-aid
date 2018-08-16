class CreateClientDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :client_details do |t|
      t.string :name
      t.integer :dob_day
      t.integer :dob_month
      t.integer :dob_year

      t.timestamps
    end
  end
end
