class ChildCareAssessmentJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      assessed:,
      result:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
