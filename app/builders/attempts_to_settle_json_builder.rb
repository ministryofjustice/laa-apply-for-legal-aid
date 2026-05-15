class AttemptsToSettleJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      proceeding_id:,
      attempts_made:,
      created_at:,
      updated_at:,
    }
  end
end
