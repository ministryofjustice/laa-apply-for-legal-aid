class HMRCResponseJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      submission_id:,
      use_case:,
      response:,
      created_at:,
      updated_at:,
      url:,
      owner_type:,
      owner_id:,
    }
  end
end
