class AllegationJsonBuilder < BaseJsonBuilder
  def attribute_hash
    {
      id:,
      legal_aid_application_id:,
      denies_all:,
      additional_information:,
      created_at:,
      updated_at:,
    }
  end
end
