class BenefitCheckResultJsonBuilder < BaseJsonBuilder
  def attribute_hash
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
