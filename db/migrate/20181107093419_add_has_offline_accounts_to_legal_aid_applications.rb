class AddHasOfflineAccountsToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :has_offline_accounts, :boolean
  end
end
