class VehicleJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      estimated_value:,
      payment_remaining:,
      used_regularly:,
      legal_aid_application_id:,
      created_at:,
      updated_at:,
      more_than_three_years_old:,
      owner:,
    }
  end
end
