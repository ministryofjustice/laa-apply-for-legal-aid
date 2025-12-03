class BankAccountJsonBuilder < BaseJsonBuilder
  # TODO: AP-6376 DO WE NEED TO SEND THIS AT ALL, IF SO WAIT UNTIL DATATSTORE USES AUTHENTICATION
  def as_json
    {
      id:,
      # account_number:,
      account_type:,
      # balance:,
      bank_provider_id:,
      created_at:,
      currency:,
      name:,
      # sort_code:,
      # true_layer_balance_response:,
      true_layer_id:,
      # true_layer_response:,
      bank_transactions: bank_transactions.map { |bt| BankTransactionJsonBuilder.build(bt).as_json },
    }
  end
end
