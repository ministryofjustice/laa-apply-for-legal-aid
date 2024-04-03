class RenameCountryToCountryCode < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      rename_column :addresses, :country, :country_code
    end
  end
end
