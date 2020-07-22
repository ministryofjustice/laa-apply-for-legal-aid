class TestFieldProviders < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :test_json, :json
  end
end
