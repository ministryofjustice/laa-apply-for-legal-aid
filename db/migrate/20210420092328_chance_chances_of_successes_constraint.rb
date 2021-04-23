class ChanceChancesOfSuccessesConstraint < ActiveRecord::Migration[6.1]
  def change
    change_column_null :chances_of_successes, :legal_aid_application_id, :uuid, true
  end
end
