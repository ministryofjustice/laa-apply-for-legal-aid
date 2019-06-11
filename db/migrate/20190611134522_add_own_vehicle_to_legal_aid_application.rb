class AddOwnVehicleToLegalAidApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :own_vehicle, :boolean
  end
end
