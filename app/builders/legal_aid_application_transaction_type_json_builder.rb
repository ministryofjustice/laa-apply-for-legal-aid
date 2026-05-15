class LegalAidApplicationTransactionTypeJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      transaction_type_id:,
      transaction_type: TransactionTypeJsonBuilder.build(transaction_type).as_json,
      created_at:,
      updated_at:,
      owner_type:,
      owner_id:,
    }
  end
end
