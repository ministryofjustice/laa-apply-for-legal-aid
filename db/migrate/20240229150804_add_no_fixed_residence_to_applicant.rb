class AddNoFixedResidenceToApplicant < ActiveRecord::Migration[7.1]
  def change
    add_column :applicants, :no_fixed_residence, :boolean
  end
end
