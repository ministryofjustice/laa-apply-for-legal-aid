class FinalHearingJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      work_type:,
      listed:,
      date:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
