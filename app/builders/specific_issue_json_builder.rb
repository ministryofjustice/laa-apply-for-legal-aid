class SpecificIssueJsonBuilder
  extend NilSafeBuilder

  def initialize(specific_issue)
    @specific_issue = specific_issue
  end

  attr_reader :specific_issue

  delegate :id,
           :details,
           :created_at,
           :updated_at,
           to: :specific_issue

  def as_json
    return unless specific_issue

    {
      id:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
