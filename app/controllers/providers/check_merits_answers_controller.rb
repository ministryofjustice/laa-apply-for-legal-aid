module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      legal_aid_application.create_opponent! unless legal_aid_application.opponent
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
      application_proceeding_type
    end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports! if legal_aid_application.may_generate_reports?
        legal_aid_application.merits_complete!
      end
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      if Setting.allow_multiple_proceedings?
        redirect_to providers_legal_aid_application_gateway_evidence_path(legal_aid_application)
      else
        redirect_to providers_merits_task_list_chances_of_success_index_path(application_proceeding_type)
      end
    end

    private

    def application_proceeding_type
      @application_proceeding_type ||= legal_aid_application.lead_application_proceeding_type
    end
  end
end
