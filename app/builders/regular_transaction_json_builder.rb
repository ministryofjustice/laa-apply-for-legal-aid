class RegularTransactionJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      transaction_type_id:,
      transaction_type: TransactionTypeJsonBuilder.build(transaction_type).as_json,
      amount:,
      frequency:,
      created_at:,
      updated_at:,
      description:,
      owner_type:,
      owner_id:,
    }
  end
end
