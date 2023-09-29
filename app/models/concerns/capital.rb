module Capital
  def positive?
    amount_attributes.values.any? { |v| v.present? && v.positive? }
  end

  def amount_attributes
    shared_attributes.except("partner_offline_current_accounts", "partner_offline_savings_accounts")
  end

  def shared_attributes
    attributes.except("id", "legal_aid_application_id", "updated_at", "created_at", "none_selected", "no_account_selected", "no_partner_account_selected")
  end
end
