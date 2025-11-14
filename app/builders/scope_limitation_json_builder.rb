class ScopeLimitationJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      scope_type:,
      code:,
      meaning:,
      description:,
      hearing_date:,
      limitation_note:,
      created_at:,
      updated_at:,
    }
  end
end
