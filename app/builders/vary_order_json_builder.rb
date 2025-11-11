class VaryOrderJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
