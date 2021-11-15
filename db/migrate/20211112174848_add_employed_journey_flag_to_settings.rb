class AddEmployedJourneyFlagToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :enable_employed_journey, :boolean, null: false, default: false
  end
end
