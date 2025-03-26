class RemovePurchasedOnFromVehicle < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :vehicles, :purchased_on, :date
    end
  end
end
