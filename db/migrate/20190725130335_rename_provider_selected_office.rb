class RenameProviderSelectedOffice < ActiveRecord::Migration[5.2]
  def change
    rename_column :providers, :office_id, :selected_office_id
  end
end
