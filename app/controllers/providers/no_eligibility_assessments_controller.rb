module Providers
  class NoEligibilityAssessmentsController < ProviderBaseController
    def show
      submission
      write_cfe_result
      legal_aid_application.provider_enter_merits! unless legal_aid_application.provider_entering_merits?
      @result_partial = ResultsPanelSelector.call(legal_aid_application)
    end

    def update
      continue_or_draft
    end

    def submission
      @submission ||= CFE::Submission.create!(legal_aid_application_id: legal_aid_application.id, aasm_state: "cfe_not_called")
    end

    def write_cfe_result
      CFE::Empty::Result.create!(
        legal_aid_application_id: legal_aid_application.id,
        submission_id: @submission.id,
        result: CFE::Empty::EmptyResult.blank_cfe_result.to_json,
        type: "CFE::Empty::Result",
      )
    end
  end
end
