class IndividualJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      created_at:,
      first_name:,
      last_name:,
      updated_at:,
    }
  end
end
