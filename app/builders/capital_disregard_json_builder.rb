class CapitalDisregardJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      name:,
      mandatory:,
      amount:,
      date_received:,
      payment_reason:,
      account_name:,
      created_at:,
      updated_at:,
    }
  end
end
