class AddLastNameToApplicants < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :last_name, :string
  end
end
