class ProviderJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      username:,
      type:,
      roles:,
      # sign_in_count:,
      # current_sign_in_at:,
      # last_sign_in_at:,
      # current_sign_in_ip:,
      # last_sign_in_ip:,
      created_at:,
      updated_at:,
      office_codes:,
      firm_id:,
      selected_office_id:,
      name:,
      email:,
      ccms_contact_id:,
      # cookies_enabled:,
      # cookies_saved_at:,
      # auth_provider:,
      # auth_subject_uid:,
      silas_id:,
    }
  end
end
