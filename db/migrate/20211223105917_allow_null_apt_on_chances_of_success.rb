class AllowNullAptOnChancesOfSuccess < ActiveRecord::Migration[6.1]
  def up
    # Change to allow null values on aplication_proceeding_type_id and NOT on proceeding_id
    change_column :chances_of_successes, :application_proceeding_type_id, :uuid, null: true
    change_column :attempts_to_settles, :application_proceeding_type_id, :uuid, null: true

    change_column :chances_of_successes, :proceeding_id, :uuid, null: false
    change_column :attempts_to_settles, :proceeding_id, :uuid, null: false
  end

  def down
    change_column :chances_of_successes, :application_proceeding_type_id, :uuid, null: false
    change_column :attempts_to_settles, :application_proceeding_type_id, :uuid, null: false

    change_column :chances_of_successes, :proceeding_id, :uuid, null: true
    change_column :attempts_to_settles, :proceeding_id, :uuid, null: true
  end
end
