class AddHasDependantsToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :has_dependants, :boolean
  end
end
