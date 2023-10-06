class AddExtraEmploymentInformationToPartner < ActiveRecord::Migration[7.0]
  def change
    add_column :partners, :extra_employment_information, :boolean
    add_column :partners, :extra_employment_information_details, :string
  end
end
