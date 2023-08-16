class ChangeForeignKeyOnChancesOfSuccesses < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :chances_of_successes, :proceedings
    add_foreign_key :chances_of_successes, :proceedings, on_delete: :cascade, validate: false
  end
end
