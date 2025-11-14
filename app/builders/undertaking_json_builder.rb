class UndertakingJsonBuilder < BaseJsonBuilder
  def as_json
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
