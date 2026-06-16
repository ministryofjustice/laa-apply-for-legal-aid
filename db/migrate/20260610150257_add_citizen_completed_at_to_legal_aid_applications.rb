class AddCitizenCompletedAtToLegalAidApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :legal_aid_applications, :citizen_completed_at, :datetime, precision: nil
  end
end
