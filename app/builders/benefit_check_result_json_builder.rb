class BenefitCheckResultJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      result:,
      dwp_ref:,
      created_at:,
      updated_at:,
    }
  end
end
