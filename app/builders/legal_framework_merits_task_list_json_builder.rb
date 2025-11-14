class LegalFrameworkMeritsTaskListJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      serialized_data:,
      created_at:,
      updated_at:,
    }
  end
end
