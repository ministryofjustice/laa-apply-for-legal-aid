class SetNewProceedingFieldsToNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:proceedings, :matter_type, false)
    change_column_null(:proceedings, :category_of_law, false)
    change_column_null(:proceedings, :category_law_code, false)
  end
end
