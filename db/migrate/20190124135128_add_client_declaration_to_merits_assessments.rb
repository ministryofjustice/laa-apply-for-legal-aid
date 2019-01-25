class AddClientDeclarationToMeritsAssessments < ActiveRecord::Migration[5.2]
  def change
    add_column :merits_assessments, :client_merits_declaration, :boolean
  end
end
