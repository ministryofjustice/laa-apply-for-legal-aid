module Providers
  class NoEligibilityAssessmentsController < ProviderBaseController
    include CFEResultMockable

    def show
      cfe_assessment_or_mock
      legal_aid_application.provider_enter_merits! unless legal_aid_application.provider_entering_merits?
      @result_partial = "shared/assessment_results/no_cfe_result"
    end

    def update
      continue_or_draft
    end

    def cfe_assessment_or_mock
      employed_and_hmrc_response? ? check_financial_eligibility : mark_as_cfe_result_skipped!
    end

  private

    def employed_and_hmrc_response?
      @legal_aid_application.applicant.employed? && @legal_aid_application.hmrc_responses.exists?
    end

    def check_financial_eligibility
      CFE::SubmissionManager.call(legal_aid_application.id)
    end
  end
end
