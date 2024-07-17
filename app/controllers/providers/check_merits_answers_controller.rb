module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      @form = LegalAidApplications::ConfirmSeparateRepresentationForm.new(model: legal_aid_application)

      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
    end

    def continue
      return continue_or_draft unless params[:legal_aid_application]

      @form = LegalAidApplications::ConfirmSeparateRepresentationForm.new(form_params)

      unless save_continue_or_draft(@form)
        render :show, status: :unprocessable_content
      end
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

  private

    def back_path
      return providers_legal_aid_application_uploaded_evidence_collection_path(legal_aid_application) if legal_aid_application.evidence_is_required?

      providers_legal_aid_application_merits_task_list_path(legal_aid_application)
    end

    def form_params
      merge_with_model(legal_aid_application) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:separate_representation_required)
      end
    end
  end
end
