class LatestIncidentJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      occurred_on:,
      details:,
      legal_aid_application_id:,
      created_at:,
      updated_at:,
      told_on:,
      first_contact_date:,
    }
  end
end
