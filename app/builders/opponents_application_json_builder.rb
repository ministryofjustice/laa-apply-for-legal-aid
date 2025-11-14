class OpponentsApplicationJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      has_opponents_application:,
      reason_for_applying:,
      created_at:,
      updated_at:,
    }
  end
end
