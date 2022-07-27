class AddUsedDelegatedFunctionsToProceeding < ActiveRecord::Migration[7.0]
  def up
    change_table :proceedings, bulk: true do |t|
      t.boolean :used_delegated_functions
    end
    Proceeding.where.not(used_delegated_functions_on: nil).update_all(used_delegated_functions: true)
    Proceeding.where(used_delegated_functions_on: nil).update_all(used_delegated_functions: false)
  end

  def down
    change_table :proceedings, bulk: true do |t|
      t.remove :used_delegated_functions
    end
  end
end
