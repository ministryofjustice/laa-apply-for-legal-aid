module Providers
  class CheckProviderAnswersController < ProviderBaseController
    def index
      @proceeding_types = legal_aid_application.proceeding_types
      @applicant = legal_aid_application.applicant
      @read_only = legal_aid_application.read_only?
      @address = @applicant.addresses.first
      legal_aid_application.check_your_answers! unless legal_aid_application.checking_answers? || legal_aid_application.provider_submitted?
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

    def continue
      legal_aid_application.answers_checked! unless draft_selected?
      continue_or_draft
    end
  end
end
