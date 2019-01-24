class AddClientDeclarationToMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :client_merits_declaration, :boolean
  #  add_column :merits_assessments, :client_merits_declaration_at, :datetime
  end
end
