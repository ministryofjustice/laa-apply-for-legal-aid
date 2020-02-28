class AddOlderThanThreeYearsToVehicles < ActiveRecord::Migration[6.0]
  def change
    add_column :vehicles, :more_than_three_years_old, :boolean, default: nil
  end
end
