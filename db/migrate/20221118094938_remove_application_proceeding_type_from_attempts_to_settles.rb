class RemoveApplicationProceedingTypeFromAttemptsToSettles < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :attempts_to_settles, :application_proceeding_type_id, :uuid, null: true
    end
  end
end
