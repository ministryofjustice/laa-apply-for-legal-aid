class AddNameAndEmailToProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :name, :string
    add_column :providers, :email, :string
  end
end
