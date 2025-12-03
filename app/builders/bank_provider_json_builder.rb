class BankProviderJsonBuilder < BaseJsonBuilder
  # TODO: AP-6376 DO WE NEED TO SEND THIS AT ALL, IF SO WAIT UNTIL DATATSTORE USED AUTHENTICATION
  def as_json
    {
      id:,
      applicant_id:,
      # true_layer_response:,
      # credentials_id:,
      name:,
      # true_layer_provider_id:,
      created_at:,
      updated_at:,
      bank_account_holders: bank_account_holders.map { |bah| BankAccountHolderJsonBuilder.build(bah).as_json },
      bank_accounts: bank_accounts.map { |ba| BankAccountJsonBuilder.build(ba).as_json },
      # main_account_holder: # TODO??
    }
  end
end
