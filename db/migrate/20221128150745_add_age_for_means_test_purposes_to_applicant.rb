class AddAgeForMeansTestPurposesToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :age_for_means_test_purposes, :integer
  end
end
