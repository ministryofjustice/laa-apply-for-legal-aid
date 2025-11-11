class InvolvedChildJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      full_name:,
      date_of_birth:,
      created_at:,
      updated_at:,
      ccms_opponent_id:,
    }
  end
end
