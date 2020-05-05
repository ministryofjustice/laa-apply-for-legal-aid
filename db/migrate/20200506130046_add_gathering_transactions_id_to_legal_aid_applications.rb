class AddGatheringTransactionsIdToLegalAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :legal_aid_applications, :gathering_transactions_jid, :string
  end
end
