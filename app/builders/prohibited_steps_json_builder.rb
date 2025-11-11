class ProhibitedStepsJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      uk_removal:,
      details:,
      created_at:,
      updated_at:,
    }
  end
end
