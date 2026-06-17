class BankAccountHolderJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      addresses:,
      bank_provider_id:,
      created_at:,
      date_of_birth:,
      full_name:,
      true_layer_response:,
      updated_at:,
    }
  end
end
