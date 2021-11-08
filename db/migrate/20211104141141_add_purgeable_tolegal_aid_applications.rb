class AddPurgeableTolegalAidApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :purgeable_on, :date, default: nil
  end
end
