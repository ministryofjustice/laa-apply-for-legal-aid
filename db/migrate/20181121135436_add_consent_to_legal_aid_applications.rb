class AddConsentToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :open_banking_consent, :string
    add_column :legal_aid_applications, :consented_at, :datetime
  end
end
