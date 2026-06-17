class BankTransactionJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      amount:,
      bank_account_id:,
      created_at:,
      currency:,
      description:,
      flags:,
      happened_at:,
      merchant:,
      meta_data:,
      operation:,
      running_balance:,
      transaction_type_id:,
      true_layer_id:,
      true_layer_response:,
      updated_at:,
      transaction_type: TransactionTypeJsonBuilder.build(transaction_type).as_json,
    }
  end
end
