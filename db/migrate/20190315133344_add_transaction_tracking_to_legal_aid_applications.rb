class AddTransactionTrackingToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :transaction_period_start_at, :datetime
    add_column :legal_aid_applications, :transaction_period_finish_at, :datetime
    add_column :legal_aid_applications, :transactions_gathered, :boolean
  end
end
