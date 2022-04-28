class AddClientDeclarationConfirmedAtToLegalAidApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :client_declaration_confirmed_at, :datetime
  end
end
