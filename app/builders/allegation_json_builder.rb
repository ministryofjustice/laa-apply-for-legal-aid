class AllegationJsonBuilder < BaseJsonBuilder
  def as_json
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
