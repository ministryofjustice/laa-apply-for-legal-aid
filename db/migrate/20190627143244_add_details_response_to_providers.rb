class AddDetailsResponseToProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :details_response, :json
  end
end
