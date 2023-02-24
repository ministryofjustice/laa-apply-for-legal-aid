module Providers
  class AboutTheFinancialAssessmentsController < ProviderBaseController
    def show
      redirect_to start_after_means_complete_path if legal_aid_application.provider_entering_merits? || legal_aid_application.provider_assessing_means?

      @applicant = legal_aid_application.applicant
    end

    def update
      return continue_or_draft if draft_selected?

      if ready_for_citizen_to_enter_financial_details?
        legal_aid_application.await_applicant!
        send_emails_to_citizen
      end
      go_forward
    end

  private

    def send_emails_to_citizen
      CitizenEmailService.new(legal_aid_application).send_email
      SubmitCitizenReminderService.new(legal_aid_application).send_email
    end

    def ready_for_citizen_to_enter_financial_details?
      !legal_aid_application.applicant_entering_means?
    end

    def start_after_means_complete_path
      Flow::KeyPoint.path_for(
        key_point: :start_after_applicant_completes_means,
        journey: :providers,
        legal_aid_application:,
      )
    end
  end
end
