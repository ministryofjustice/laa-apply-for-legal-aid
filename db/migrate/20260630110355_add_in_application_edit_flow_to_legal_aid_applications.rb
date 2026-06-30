class AddInApplicationEditFlowToLegalAidApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :legal_aid_applications, :in_application_edit_flow, :boolean, null: false, default: false
  end
end
