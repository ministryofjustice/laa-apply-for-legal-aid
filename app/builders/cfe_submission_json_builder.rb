class CFESubmissionJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      assessment_id:,
      aasm_state:,
      error_message:,
      cfe_result:,
      created_at:,
      updated_at:,
    }
  end
end
