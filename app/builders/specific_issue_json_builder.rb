class SpecificIssueJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      proceeding_id:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
