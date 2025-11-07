class DomesticAbuseSummaryJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      warning_letter_sent:,
      warning_letter_sent_details:,
      police_notified:,
      police_notified_details:,
      bail_conditions_set:,
      bail_conditions_set_details:,
      created_at:,
      updated_at:,
    }
  end
end
