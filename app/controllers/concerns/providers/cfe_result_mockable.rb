module Providers
  module CFEResultMockable
  private

    def mark_as_cfe_result_skipped!
      CFE::Empty::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: submission.id,
        result: CFE::Empty::EmptyResult.blank_cfe_result.to_json,
        type: "CFE::Empty::Result",
      )
    end

    def submission
      CFE::Submission.create!(legal_aid_application_id: legal_aid_application.id, aasm_state: "cfe_not_called")
    end
  end
end
