class RemoveDeclarationAcceptedAtFromLegalAidApplications < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :legal_aid_applications, :declaration_accepted_at, :datetime
    end
  end
end
