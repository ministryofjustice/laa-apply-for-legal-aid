class UpdateChancesOfSuccesses < ActiveRecord::Migration[6.1]
  def up
    add_belongs_to :chances_of_successes, :application_proceeding_type, foreign_key: true, null: false, type: :uuid
    change_column_null :chances_of_successes, :legal_aid_application_id, true
  end

  def down
    change_column_null :chances_of_successes, :legal_aid_application_id, false
    remove_belongs_to :chances_of_successes, :application_proceeding_type
  end
end
