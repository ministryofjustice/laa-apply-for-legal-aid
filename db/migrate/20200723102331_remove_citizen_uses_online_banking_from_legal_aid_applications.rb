class RemoveCitizenUsesOnlineBankingFromLegalAidApplications < ActiveRecord::Migration[6.0]
  def change
    remove_column :legal_aid_applications, :citizen_uses_online_banking
  end
end
