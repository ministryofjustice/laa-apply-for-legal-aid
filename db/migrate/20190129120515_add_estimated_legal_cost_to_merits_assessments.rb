class AddEstimatedLegalCostToMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :estimated_legal_cost, :decimal, precision: 10, scale: 2
  end
end
