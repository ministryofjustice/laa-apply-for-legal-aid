class AddBuildingNumberNameToAddresses < ActiveRecord::Migration[7.1]
  def change
    add_column :addresses, :building_number_name, :string
  end
end
