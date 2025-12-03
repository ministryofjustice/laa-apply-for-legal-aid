class OrganisationJsonBuilder < BaseJsonBuilder
  def as_json
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
