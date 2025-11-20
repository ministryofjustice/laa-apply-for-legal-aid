class AddAddressToOffices < ActiveRecord::Migration[8.1]
  def change
    add_column :offices, :address_line_one, :string
    add_column :offices, :address_line_two, :string
    add_column :offices, :address_line_three, :string
    add_column :offices, :address_line_four, :string
    add_column :offices, :city, :string
    add_column :offices, :county, :string
    add_column :offices, :postcode, :string
  end
end
