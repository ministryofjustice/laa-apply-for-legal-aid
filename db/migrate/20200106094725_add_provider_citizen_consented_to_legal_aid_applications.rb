class AddProviderCitizenConsentedToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :provider_received_citizen_consent, :boolean
    add_column :legal_aid_applications, :citizen_uses_online_banking, :boolean
  end
end
