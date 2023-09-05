class RenameOrganisationsColumns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :organisations, :ccms_code, :ccms_type_code
      rename_column :organisations, :description, :ccms_type_text
    end
  end
end
