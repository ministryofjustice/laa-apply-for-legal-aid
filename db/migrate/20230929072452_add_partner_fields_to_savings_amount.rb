class AddPartnerFieldsToSavingsAmount < ActiveRecord::Migration[7.0]
  def change
    add_column :savings_amounts, :partner_offline_current_accounts, :numeric
    add_column :savings_amounts, :partner_offline_savings_accounts, :numeric
    add_column :savings_amounts, :no_partner_account_selected, :boolean
  end
end
