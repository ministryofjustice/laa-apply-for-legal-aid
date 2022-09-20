class MigrateAndClearProceedingsScopeLimitations < ActiveRecord::Migration[7.0]
  def up
    change_table :proceedings, bulk: true do |t|
      t.remove :substantive_scope_limitation_code
      t.remove :substantive_scope_limitation_meaning
      t.remove :substantive_scope_limitation_description
      t.remove :delegated_functions_scope_limitation_code
      t.remove :delegated_functions_scope_limitation_meaning
      t.remove :delegated_functions_scope_limitation_description
    end
  end

  def down
    change_table :proceedings, bulk: true do |t|
      t.string :substantive_scope_limitation_code
      t.string :substantive_scope_limitation_meaning
      t.string :substantive_scope_limitation_description
      t.string :delegated_functions_scope_limitation_code
      t.string :delegated_functions_scope_limitation_meaning
      t.string :delegated_functions_scope_limitation_description
    end
  end
end
