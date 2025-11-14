class StatementOfCaseJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      statement:,
      created_at:,
      updated_at:,
      provider_uploader_id:,
      upload:,
      typed:,
    }
  end
end
