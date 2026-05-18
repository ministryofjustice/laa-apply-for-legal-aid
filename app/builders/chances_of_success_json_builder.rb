class ChancesOfSuccessJsonBuilder < BaseJsonBuilder
  def attribute_hash
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
