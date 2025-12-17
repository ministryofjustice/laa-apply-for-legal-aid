class FirmJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      created_at:,
      updated_at:,
      ccms_id:,
      name:,
    }
  end
end
