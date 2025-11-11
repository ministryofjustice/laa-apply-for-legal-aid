class AttemptsToSettleJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      attempts_made:,
      created_at:,
      updated_at:,
    }
  end
end
