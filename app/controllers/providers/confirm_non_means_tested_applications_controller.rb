module Providers
  class ConfirmNonMeansTestedApplicationsController < ProviderBaseController
    include ApplicantDetailsCheckable

    def show
      details_checked! unless details_checked?
    end

    def update
      mark_as_benefit_check_skipped!
      mark_as_cfe_result_skipped!
      continue_or_draft
    end

  private

    def mark_as_benefit_check_skipped!
      legal_aid_application.create_benefit_check_result!(result: "skipped:no_means_test_required")
    end

    def mark_as_cfe_result_skipped!
      write_mock_cfe_result
    end

    def write_mock_cfe_result
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
