class ProviderJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      username:,
      type:,
      roles:,
      created_at:,
      updated_at:,
      office_codes:,
      firm_id:,
      selected_office_id:,
      name:,
      email:,
      ccms_contact_id:,
      silas_id:,
    }
  end
end
