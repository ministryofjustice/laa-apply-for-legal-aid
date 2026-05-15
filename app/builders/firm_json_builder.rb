class FirmJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      created_at:,
      updated_at:,
      ccms_id:,
      name:,
    }
  end
end
