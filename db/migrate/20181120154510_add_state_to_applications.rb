class AddStateToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :state, :string
  end
end
