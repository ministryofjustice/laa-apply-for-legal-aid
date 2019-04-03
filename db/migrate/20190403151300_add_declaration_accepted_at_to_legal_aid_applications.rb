class AddDeclarationAcceptedAtToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :declaration_accepted_at, :datetime
  end
end
