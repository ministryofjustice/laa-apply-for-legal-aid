class RemoveUsesOnlineBankingFromApplicants < ActiveRecord::Migration[5.2]
  def change
    remove_column :applicants, :uses_online_banking
  end
end
