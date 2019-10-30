class AddUseProviderDetailsApiToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :use_mock_provider_details, :boolean, null: false, default: true
  end
end
