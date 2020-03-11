module Capital
  def positive?
    amount_attributes.values.any? { |v| v.present? && v.positive? }
  end

  def amount_attributes
    attributes.except('id', 'legal_aid_application_id', 'updated_at', 'created_at', 'none_selected', 'no_account_selected')
  end
end
