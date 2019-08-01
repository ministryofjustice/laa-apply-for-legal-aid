class AddRestrictionsToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :has_restrictions, :boolean
    add_column :legal_aid_applications, :restrictions_details, :string
  end
end
