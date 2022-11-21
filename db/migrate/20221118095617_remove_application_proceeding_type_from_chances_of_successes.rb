class RemoveApplicationProceedingTypeFromChancesOfSuccesses < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :chances_of_successes, :application_proceeding_type_id, :uuid, null: true
    end
  end
end
