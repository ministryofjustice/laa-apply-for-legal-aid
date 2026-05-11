class AddEntraIdAccessTokenAndEntraIdRefreshTokenToProviders < ActiveRecord::Migration[8.1]
  def change
    add_column :providers, :entra_id_access_token, :text
    add_column :providers, :entra_id_refresh_token, :text
  end
end
