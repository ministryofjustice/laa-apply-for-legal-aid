class AddExtraEmploymentInformationToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :extra_employment_information, :boolean
    add_column :applicants, :extra_employment_information_details, :string
  end
end
