module Providers
  class ConfirmClientDeclarationsController < ProviderBaseController
    def show
      @form = LegalAidApplications::ConfirmClientDeclarationForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::ConfirmClientDeclarationForm.new(form_params)

      unless save_continue_or_draft(@form)
        render :show, status: :unprocessable_content
      end
    end

  private

    def form_params
      merge_with_model(legal_aid_application) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:client_declaration_confirmed)
      end
    end
  end
end
