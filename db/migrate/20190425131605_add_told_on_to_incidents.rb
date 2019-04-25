class AddToldOnToIncidents < ActiveRecord::Migration[5.2]
  def change
    add_column :incidents, :told_on, :date
  end
end
