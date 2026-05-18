class MatterOppositionJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      reason:,
      created_at:,
      updated_at:,
      matter_opposed:,
    }
  end
end
