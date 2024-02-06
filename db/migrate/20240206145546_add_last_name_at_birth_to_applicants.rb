class AddLastNameAtBirthToApplicants < ActiveRecord::Migration[7.1]
  def change
    add_column :applicants, :last_name_at_birth, :string
    add_column :applicants, :changed_last_name, :boolean
  end
end
