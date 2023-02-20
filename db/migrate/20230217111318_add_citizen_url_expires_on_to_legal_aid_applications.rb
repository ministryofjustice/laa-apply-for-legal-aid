class AddCitizenUrlExpiresOnToLegalAidApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :legal_aid_applications, :citizen_url_expires_on, :date, null: true
  end
end
