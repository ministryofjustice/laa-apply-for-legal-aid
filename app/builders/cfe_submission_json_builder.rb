class CFESubmissionJsonBuilder < BaseJsonBuilder
  def as_json
    {
      id:,
      legal_aid_application_id:,
      assessment_id:,
      aasm_state:,
      error_message:,
      cfe_result:,
      # result: CfeSubmissionResultJsonBuilder.build(result).as_json, NOT NEEDED - same as cfe_result
      # submission_histories: submission_histories.map { |sh| CfeSubmissionHistoryJsonBuilder.build(sh).as_json }, NOT NEEDED?
      created_at:,
      updated_at:,
    }
  end
end
