class AllowNullAptOnChancesOfSuccess < ActiveRecord::Migration[6.1]
  def change
    # Change to allow null values
    change_column :chances_of_successes, :application_proceeding_type_id, :uuid, null: true
  end
end
