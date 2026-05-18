class ProhibitedStepsJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      proceeding_id:,
      uk_removal:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
