module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      legal_aid_application.create_opponent! unless legal_aid_application.opponent
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
    end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports! if legal_aid_application.may_generate_reports?
        chances_of_success.submit!
      end
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      redirect_to providers_legal_aid_application_chances_of_success_index_path
    end

    private

    def chances_of_success
      @chances_of_success ||= legal_aid_application.chances_of_success || legal_aid_application.build_chances_of_success
    end
  end
end
