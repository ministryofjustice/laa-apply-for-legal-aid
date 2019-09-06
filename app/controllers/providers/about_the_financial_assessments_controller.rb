module Providers
  class AboutTheFinancialAssessmentsController < ProviderBaseController
    def show
      redirect_to start_after_means_complete_path if legal_aid_application.means_completed?

      @applicant = legal_aid_application.applicant
    end

    def update
      return continue_or_draft if draft_selected?

      unless legal_aid_application.provider_submitted?
        legal_aid_application.provider_submit!
        CitizenEmailService.new(legal_aid_application).send_email
      end
      go_forward
    end

    private

    def start_after_means_complete_path
      Flow::KeyPoint.path_for(
        key_point: :start_after_applicant_completes_means,
        journey: :providers,
        legal_aid_application: legal_aid_application
      )
    end
  end
end
