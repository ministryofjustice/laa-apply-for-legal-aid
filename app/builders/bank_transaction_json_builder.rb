class BankTransactionJsonBuilder < BaseJsonBuilder
  # TODO: AP-6376 DO WE NEED TO SEND THIS AT ALL, IF SO WAIT UNTIL DATATSTORE USES AUTHENTICATION
  def as_json
    {
      id:,
      # amount:,
      # bank_account_id:,
      created_at:,
      currency:,
      description:,
      # flags:,
      happened_at:,
      # merchant:,
      # meta_data:,
      operation:,
      # running_balance:,
      transaction_type_id:,
      true_layer_id:,
      # true_layer_response:,
      updated_at:,
      transaction_type: TransactionTypeJsonBuilder.build(transaction_type).as_json,
    }
  end
end
