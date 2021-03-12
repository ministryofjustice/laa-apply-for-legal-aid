class RenameEvidenceAvailableToHasEvidenceOfBenefit < ActiveRecord::Migration[6.1]
  def change
    rename_column :dwp_overrides, :evidence_available, :has_evidence_of_benefit
  end
end
