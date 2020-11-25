class RemoveClientReceivedLegalHelpFromMeritsAssessment < ActiveRecord::Migration[6.0]
  def up
    remove_column :merits_assessments, :client_received_legal_help
  end

  def down
    add_column :merits_assessments, :client_received_legal_help, :boolean
  end
end
