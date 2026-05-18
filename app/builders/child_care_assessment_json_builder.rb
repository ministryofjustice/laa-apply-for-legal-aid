class ChildCareAssessmentJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      proceeding_id:,
      assessed:,
      result:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
