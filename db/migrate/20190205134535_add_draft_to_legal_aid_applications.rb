class AddDraftToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :draft, :boolean
  end
end
