class AddEmploymentFieldsToApplicant < ActiveRecord::Migration[8.1]
  def change
    add_column :applicants, :full_employment_details, :string
  end
end
