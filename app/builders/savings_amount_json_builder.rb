class SavingsAmountJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      offline_current_accounts:,
      cash:,
      other_person_account:,
      national_savings:,
      plc_shares:,
      peps_unit_trusts_capital_bonds_gov_stocks:,
      life_assurance_endowment_policy:,
      created_at:,
      updated_at:,
      none_selected:,
      offline_savings_accounts:,
      no_account_selected:,
      partner_offline_current_accounts:,
      partner_offline_savings_accounts:,
      no_partner_account_selected:,
      joint_offline_current_accounts:,
      joint_offline_savings_accounts:,
    }
  end
end
