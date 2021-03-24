module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      legal_aid_application.create_opponent! unless legal_aid_application.opponent
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
    end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports! if legal_aid_application.may_generate_reports?
        merits_assessment.submit!
      end
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      redirect_to providers_legal_aid_application_success_likely_index_path
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end
  end
end
