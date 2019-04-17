class AddSubmittedAtToMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :submitted_at, :datetime
    remove_column :merits_assessments, :client_merits_declaration, :boolean
  end
end
