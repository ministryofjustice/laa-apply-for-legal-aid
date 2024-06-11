class AddAddressLineThreeToAddress < ActiveRecord::Migration[7.1]
  def change
    add_column :addresses, :address_line_three, :string
  end
end
