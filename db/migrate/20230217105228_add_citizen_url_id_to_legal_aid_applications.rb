class AddCitizenUrlIdToLegalAidApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :legal_aid_applications, :citizen_url_id, :string, null: true
  end
end
