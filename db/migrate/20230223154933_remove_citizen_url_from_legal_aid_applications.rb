class RemoveCitizenUrlFromLegalAidApplications < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :legal_aid_applications, :citizen_url_id, :string, null: true
      remove_column :legal_aid_applications, :citizen_url_expires_on, :date, null: true
    end
  end
end
