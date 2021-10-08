class MakeProceedingDfDatesNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :proceedings, :used_delegated_functions_on, true
    change_column_null :proceedings, :used_delegated_functions_reported_on, true
  end
end
