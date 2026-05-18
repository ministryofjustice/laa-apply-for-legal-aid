class OpponentsApplicationJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      proceeding_id:,
      has_opponents_application:,
      reason_for_applying:,
      created_at:,
      updated_at:,
    }
  end
end
