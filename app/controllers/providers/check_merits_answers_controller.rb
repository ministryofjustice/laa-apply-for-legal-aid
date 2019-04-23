module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      @merits = legal_aid_application.merits_assessment
      @statement_of_case = legal_aid_application.statement_of_case
      @respondent = legal_aid_application.respondent || legal_aid_application.create_respondent!
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
    end

    def continue
      legal_aid_application.checked_merits_answers! unless draft_selected? || legal_aid_application.checked_merits_answers?
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end
  end
end
