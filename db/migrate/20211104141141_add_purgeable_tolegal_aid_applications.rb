class AddPurgeableTolegalAidApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :purgeable, :boolean, default: false
  end
end
