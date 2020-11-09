class AddInvalidLoginToProviders < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :invalid_login_details, :string, default: nil
  end
end
