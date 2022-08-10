module Providers
  class NoEligibilityAssessmentsController < ProviderBaseController
    def show
      cfe_assessment_or_mock
      legal_aid_application.provider_enter_merits! unless legal_aid_application.provider_entering_merits?
      @result_partial = "shared/assessment_results/no_cfe_result"
    end

    def update
      continue_or_draft
    end

    def submission
      CFE::Submission.create!(legal_aid_application_id: legal_aid_application.id, aasm_state: "cfe_not_called")
    end

    def cfe_assessment_or_mock
      employed_and_hmrc_response? ? check_financial_eligibility : write_cfe_result
    end

    def employed_and_hmrc_response?
      @legal_aid_application.applicant.employed? && !@legal_aid_application.hmrc_responses.empty?
      # Is one of these to be preferred? Both positive below seems like it would be better?
      # @legal_aid_application.applicant.employed? && @legal_aid_application.hmrc_responses.exists?
    end

  private

    def write_cfe_result
      CFE::Empty::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: submission.id,
        result: CFE::Empty::EmptyResult.blank_cfe_result.to_json,
        type: "CFE::Empty::Result",
      )
    end

    def check_financial_eligibility
      CFE::SubmissionManager.call(legal_aid_application.id)
    end
  end
end
