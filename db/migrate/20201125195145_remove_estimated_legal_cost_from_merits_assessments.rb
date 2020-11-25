class RemoveEstimatedLegalCostFromMeritsAssessments < ActiveRecord::Migration[6.0]
  def up
    remove_column :merits_assessments, :estimated_legal_cost
  end

  def down
    add_column :merits_assessments, :estimated_legal_cost, :decimal, precision: 10, scale: 2
  end
end
