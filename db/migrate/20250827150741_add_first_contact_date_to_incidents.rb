class AddFirstContactDateToIncidents < ActiveRecord::Migration[8.0]
  def change
    add_column :incidents, :first_contact_date, :date
  end
end
