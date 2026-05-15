class UndertakingJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      offered:,
      additional_information:,
      created_at:,
      updated_at:,
    }
  end
end
