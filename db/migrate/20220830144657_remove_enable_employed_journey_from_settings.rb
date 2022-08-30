class RemoveEnableEmployedJourneyFromSettings < ActiveRecord::Migration[7.0]
  def change
    remove_column :settings, :enable_employed_journey, :boolean, null: false, default: false
  end
end
