class BankProviderJsonBuilder < BaseJsonBuilder
  # DO WE NEED TO SEND THIS AT ALL, IF SO WAIT UNTIL DATATSTORE USED AUTHENTICATION
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
      # bank_account_holders: # TODO
      # bank_accounts: # TODO
      # main_account_holder: # TODO
    }
  end
end
