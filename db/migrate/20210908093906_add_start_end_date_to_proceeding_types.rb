class AddStartEndDateToProceedingTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :proceeding_types, :start_date, :date
    add_column :proceeding_types, :end_date, :date
  end
end
