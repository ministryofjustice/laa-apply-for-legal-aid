class RemoveProceedingsScopeLimitations < ActiveRecord::Migration[7.0]
  def up
    raise StandardError, "Proceeding table has scope limitation data" if any_proceeding_data_present?

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

  # rubocop:disable Rails/WhereNotWithMultipleConditions
  def any_proceeding_data_present?
    Proceeding.where.not(substantive_scope_limitation_code: nil,
                         substantive_scope_limitation_meaning: nil,
                         substantive_scope_limitation_description: nil,
                         delegated_functions_scope_limitation_code: nil,
                         delegated_functions_scope_limitation_meaning: nil,
                         delegated_functions_scope_limitation_description: nil).count.positive?
  end
  # rubocop:enable Rails/WhereNotWithMultipleConditions
end
