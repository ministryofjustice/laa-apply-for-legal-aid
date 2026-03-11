class AddFirstNameLastNameToInvolvedChildren < ActiveRecord::Migration[8.1]
  def change
    add_column :involved_children, :first_name, :string
    add_column :involved_children, :last_name, :string
  end
end
