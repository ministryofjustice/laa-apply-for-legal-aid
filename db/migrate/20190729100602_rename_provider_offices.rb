class RenameProviderOffices < ActiveRecord::Migration[5.2]
  def change
    rename_column :providers, :offices, :office_codes
  end
end
