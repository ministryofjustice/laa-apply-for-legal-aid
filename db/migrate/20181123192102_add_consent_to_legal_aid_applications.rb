class AddConsentToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :open_banking_consent, :boolean
    add_column :legal_aid_applications, :open_banking_consent_choice_at, :datetime
  end
end
