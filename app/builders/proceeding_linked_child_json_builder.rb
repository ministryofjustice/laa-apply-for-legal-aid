class ProceedingLinkedChildJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      involved_child_id:,
      created_at:,
      updated_at:,
    }
  end
end
