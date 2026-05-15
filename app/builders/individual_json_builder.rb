class IndividualJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      created_at:,
      first_name:,
      last_name:,
      updated_at:,
    }
  end
end
