class AddCaseAddTxIdToCCMSSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :ccms_submissions, :case_add_transaction_id, :string
  end
end
