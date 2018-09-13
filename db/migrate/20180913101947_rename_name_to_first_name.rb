class RenameNameToFirstName < ActiveRecord::Migration[5.2]
  def change
    rename_column :applicants, :name, :first_name
  end
end
