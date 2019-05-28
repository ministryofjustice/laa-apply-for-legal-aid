module Providers
  class AboutTheFinancialAssessmentsController < ProviderBaseController
    def show
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
  end
end
