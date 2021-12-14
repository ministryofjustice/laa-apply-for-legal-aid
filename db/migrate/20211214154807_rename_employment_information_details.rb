class RenameEmploymentInformationDetails < ActiveRecord::Migration[6.1]
  def change
    rename_column :legal_aid_applications, :employment_information_details, :extra_employment_information_details
  end
end
