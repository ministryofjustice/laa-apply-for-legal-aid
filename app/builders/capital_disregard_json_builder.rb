class CapitalDisregardJsonBuilder < BaseJsonBuilder
  def as_json
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
