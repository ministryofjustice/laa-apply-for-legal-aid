class AddLeadTypeToApplicationProcTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :application_proceeding_types, :lead_proceeding, :boolean, null: false, default: false
  end
end
