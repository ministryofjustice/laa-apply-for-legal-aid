class AddNewEmploymentStatusesToApplicant < ActiveRecord::Migration[6.1]
  def change
    add_column :applicants, :self_employed, :boolean, default: false
    add_column :applicants, :armed_forces, :boolean, default: false
  end
end
