class OrganisationJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      ccms_type_code:,
      ccms_type_text:,
      created_at:,
      name:,
      updated_at:,
    }
  end
end
