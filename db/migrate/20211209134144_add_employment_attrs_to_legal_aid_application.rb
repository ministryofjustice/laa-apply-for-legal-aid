class AddEmploymentAttrsToLegalAidApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :extra_employment_information, :boolean
    add_column :legal_aid_applications, :employment_information_details, :string
  end
end
