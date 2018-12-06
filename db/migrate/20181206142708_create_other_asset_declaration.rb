class CreateOtherAssetDeclaration < ActiveRecord::Migration[5.2]
  def change
    create_table :other_assets_declarations, id: :uuid do |t|
      t.uuid :legal_aid_application_id, null: false
      t.decimal :second_home_value
      t.decimal :second_home_mortgage
      t.decimal :second_home_percentage
      t.decimal :timeshare_value
      t.decimal :land_value
      t.decimal :jewellery_value
      t.decimal :vehicle_value
      t.decimal :classic_car_value
      t.decimal :money_assets_value
      t.decimal :money_owed_value
      t.decimal :trust_value

      t.timestamps
    end

    add_index :other_assets_declarations, :legal_aid_application_id, unique: true
  end
end
