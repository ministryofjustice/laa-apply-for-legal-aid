class DWPOverrideJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      passporting_benefit:,
      has_evidence_of_benefit:,
      created_at:,
      updated_at:,
    }
  end
end
