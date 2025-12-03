class LinkedApplicationJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      associated_application_id:,
      lead_application_id:,
      link_type_code:,
      target_application_id:,
      confirm_link:,
      created_at:,
      updated_at:,
    }
  end
end
