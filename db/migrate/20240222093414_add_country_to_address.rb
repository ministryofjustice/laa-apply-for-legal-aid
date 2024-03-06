class AddCountryToAddress < ActiveRecord::Migration[7.1]
  def change
    add_column :addresses, :country, :string
    Address.update_all(country: "GBR")
  end
end
