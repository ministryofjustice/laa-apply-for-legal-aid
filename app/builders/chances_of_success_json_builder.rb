class ChancesOfSuccessJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      proceeding_id:,
      application_purpose:,
      success_prospect:,
      success_prospect_details:,
      success_likely:,
      created_at:,
      updated_at:,
    }
  end
end
