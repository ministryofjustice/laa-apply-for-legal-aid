module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      legal_aid_application.create_opponent! unless legal_aid_application.opponent
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
    end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports!
        legal_aid_application.merits_complete!
      end
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

    def back_path
      if Setting.enable_evidence_upload?
        return providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application) if legal_aid_application.evidence_is_required?

        return providers_legal_aid_application_merits_task_list_path(legal_aid_application)
      end

      providers_legal_aid_application_gateway_evidence_path(legal_aid_application)
    end
  end
end
