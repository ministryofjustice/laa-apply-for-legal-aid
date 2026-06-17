class BankProviderJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      applicant_id:,
      true_layer_response:,
      credentials_id:,
      name:,
      true_layer_provider_id:,
      created_at:,
      updated_at:,
      bank_account_holders: bank_account_holders.map { |bah| BankAccountHolderJsonBuilder.build(bah).as_json },
      bank_accounts: bank_accounts.map { |ba| BankAccountJsonBuilder.build(ba).as_json },
      main_account_holder: main_account_holder ? BankAccountHolderJsonBuilder.build(main_account_holder).as_json : nil,
    }
  end
end
