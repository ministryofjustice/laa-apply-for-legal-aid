class TransactionTypeJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      name:,
      operation:,
      created_at:,
      updated_at:,
      sort_order:,
      archived_at:,
      other_income:,
      parent_id:,
    }
  end
end
