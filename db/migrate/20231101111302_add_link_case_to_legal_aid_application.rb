class AddLinkCaseToLegalAidApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :legal_aid_applications, :link_case, :boolean
  end
end
