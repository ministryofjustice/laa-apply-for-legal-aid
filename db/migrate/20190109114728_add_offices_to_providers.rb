class AddOfficesToProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :offices, :text
  end
end
