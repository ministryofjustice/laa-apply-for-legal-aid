class RemoveCompletedAtFromLegalAidApplications < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :legal_aid_applications, :completed_at, :datetime, precision: nil
    end
  end
end
