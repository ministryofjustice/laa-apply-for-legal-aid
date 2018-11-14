class AddOrganisationToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :organisation, :string
  end
end
