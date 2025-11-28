class BankAccountHolderJsonBuilder < BaseJsonBuilder
  # TODO: AP-6376 DO WE NEED TO SEND THIS AT ALL, IF SO WAIT UNTIL DATATSTORE USES AUTHENTICATION
  def as_json
    {
      id:,
      addresses:,
      bank_provider_id:,
      created_at:,
      date_of_birth:,
      full_name:,
      # true_layer_response:,
      updated_at:,
    }
  end
end
