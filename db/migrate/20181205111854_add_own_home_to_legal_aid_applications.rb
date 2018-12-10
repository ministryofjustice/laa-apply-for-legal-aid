class AddOwnHomeToLegalAidApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :own_home, :string
  end
end
