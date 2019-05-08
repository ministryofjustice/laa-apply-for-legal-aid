class AddApplicantAddTxIdToCcmsSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :ccms_submissions, :applicant_add_tx_id, :string
  end
end
