module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      @form = LegalAidApplications::ConfirmSeparateRepresentationForm.new(model: legal_aid_application)
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
    end

    def continue
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

    def back_path
      return providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application) if legal_aid_application.evidence_is_required?

      providers_legal_aid_application_merits_task_list_path(legal_aid_application)
    end
  end
end
