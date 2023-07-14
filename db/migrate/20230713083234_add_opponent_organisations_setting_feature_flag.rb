class AddOpponentOrganisationsSettingFeatureFlag < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :opponent_organisations, :boolean, null: false, default: false
  end
end
