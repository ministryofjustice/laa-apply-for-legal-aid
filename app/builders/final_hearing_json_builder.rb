class FinalHearingJsonBuilder < BaseJsonBuilder
  def attribute_hash
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
