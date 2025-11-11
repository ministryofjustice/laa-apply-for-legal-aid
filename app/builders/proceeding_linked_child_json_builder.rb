class ProceedingLinkedChildJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      involved_child_id:,
      created_at:,
      updated_at:,
    }
  end
end
