class AddApplicantAddTxIdToCCMSSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :ccms_submissions, :applicant_add_transaction_id, :string
  end
end
