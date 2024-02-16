class AddTypeToAddress < ActiveRecord::Migration[7.1]
  def change
    add_column :addresses, :location, :string
    # Set default values for existing records
    Address.update_all(location: "correspondence")
  end
end
