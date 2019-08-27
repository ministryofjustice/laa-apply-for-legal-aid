class ChangeTransactionPeriodDates < ActiveRecord::Migration[5.2]
  def change
    rename_column :legal_aid_applications, :transaction_period_start_at, :transaction_period_start_on
    rename_column :legal_aid_applications, :transaction_period_finish_at, :transaction_period_finish_on

    change_column :legal_aid_applications, :transaction_period_start_on, :date
    change_column :legal_aid_applications, :transaction_period_finish_on, :date
  end
end
