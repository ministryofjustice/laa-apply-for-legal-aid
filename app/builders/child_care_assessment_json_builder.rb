class ChildCareAssessmentJsonBuilder
  extend NilSafeBuilder

  def initialize(child_care_assessment)
    @child_care_assessment = child_care_assessment
  end

  attr_reader :child_care_assessment

  delegate :id,
           :assessed,
           :result,
           :details,
           :created_at,
           :updated_at,
           to: :child_care_assessment

  def as_json
    return unless child_care_assessment

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
