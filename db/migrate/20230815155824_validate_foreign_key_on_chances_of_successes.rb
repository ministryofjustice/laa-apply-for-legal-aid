class ValidateForeignKeyOnChancesOfSuccesses < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :chances_of_successes, :proceedings
  end
end
