class AddCareOfToAddress < ActiveRecord::Migration[7.1]
  def change
    add_column :addresses, :care_of, :string
    add_column :addresses, :care_of_first_name, :string
    add_column :addresses, :care_of_last_name, :string
    add_column :addresses, :care_of_organisation_name, :string
  end
end
