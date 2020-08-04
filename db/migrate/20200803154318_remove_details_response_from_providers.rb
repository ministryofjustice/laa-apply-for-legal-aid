class RemoveDetailsResponseFromProviders < ActiveRecord::Migration[6.0]
  def change
    remove_column :providers, :details_response, :json
  end
end
