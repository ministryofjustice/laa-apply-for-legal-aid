class RemoveProceedingsChildRelationship < ActiveRecord::Migration[8.0]
  def up
    raise StandardError, "There is mismatched child relationship data" if mismatched_relationship_data?

    safety_assured { remove_column :proceedings, :relationship_to_child, :string }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def mismatched_relationship_data?
    # potentially affected applicants
    paa = Applicant.where.not(relationship_to_children: nil)
    paa.map do |applicant|
      if applicant.legal_aid_application.proceedings.map(&:relationship_to_child).uniq != [nil]
        [applicant.relationship_to_children] == applicant.legal_aid_application.proceedings.map(&:relationship_to_child).uniq
      else
        true
      end
    end.uniq.count > 1
  end
end
