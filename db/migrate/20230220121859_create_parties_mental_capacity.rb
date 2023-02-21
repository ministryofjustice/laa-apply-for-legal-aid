class CreatePartiesMentalCapacity < ActiveRecord::Migration[7.0]
  def change
    create_table :parties_mental_capacities, id: :uuid do |t|
      t.belongs_to :legal_aid_application, null: false, foreign_key: true, type: :uuid
      t.boolean :understands_terms_of_court_order
      t.text :understands_terms_of_court_order_details

      t.timestamps
    end
  end
end
