class UrgencyJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      nature_of_urgency:,
      hearing_date_set:,
      hearing_date:,
      additional_information:,
      created_at:,
      updated_at:,
    }
  end
end
