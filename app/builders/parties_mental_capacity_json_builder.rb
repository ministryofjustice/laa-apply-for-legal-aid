class PartiesMentalCapacityJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      understands_terms_of_court_order:,
      understands_terms_of_court_order_details:,
      created_at:,
      updated_at:,
    }
  end
end
