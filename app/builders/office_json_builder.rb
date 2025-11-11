class OfficeJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      created_at:,
      updated_at:,
      ccms_id:,
      code:,
      firm_id:,
    }
  end
end
