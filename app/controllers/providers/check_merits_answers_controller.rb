module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    include ApplicationDependable
    include Flowable

    def show
      @merits = legal_aid_application.merits_assessment
      @statement_of_case = legal_aid_application.statement_of_case
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
    end

    def continue
      legal_aid_application.complete_merits! unless legal_aid_application.merits_completed?
      go_forward
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end
  end
end
