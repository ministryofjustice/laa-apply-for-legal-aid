class AddUsesOnlineBankingToApplicant < ActiveRecord::Migration[5.2]
  def change
    add_column :applicants, :uses_online_banking, :boolean
  end
end
