class RemoveOpponentOrganisationsFlagFromSettings < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :settings, :opponent_organisations, :boolean, null: false, default: false
    end
  end
end
