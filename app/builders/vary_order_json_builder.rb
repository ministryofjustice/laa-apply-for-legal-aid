class VaryOrderJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      proceeding_id:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
