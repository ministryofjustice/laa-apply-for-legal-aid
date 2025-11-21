class AppealJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      second_appeal:,
      original_judge_level:,
      court_type:,
      created_at:,
      updated_at:,
    }
  end
end
