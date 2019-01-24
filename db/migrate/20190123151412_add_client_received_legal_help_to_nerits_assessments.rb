class AddClientReceivedLegalHelpToNeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :client_received_legal_help, :boolean
  end
end
