class RenameLinkCaseToCaseClonedOnLegalAidApplication < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      rename_column :legal_aid_applications, :link_case, :case_cloned
    end
  end
end
