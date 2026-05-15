class CashTransactionJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      amount:,
      transaction_date:,
      created_at:,
      updated_at:,
      month_number:,
      transaction_type_id:,
      transaction_type: TransactionTypeJsonBuilder.build(transaction_type).as_json,
      owner_type:,
      owner_id:,
    }
  end
end
