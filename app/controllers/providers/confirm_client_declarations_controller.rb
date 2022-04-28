module Providers
  class ConfirmClientDeclarationsController < ProviderBaseController
    def show
      @form = LegalAidApplications::ConfirmClientDeclarationForm.new(model: legal_aid_application)
    end

    def update
      return continue_or_draft if draft_selected?

      @form = LegalAidApplications::ConfirmClientDeclarationForm.new(form_params)
      if @form.valid?
        legal_aid_application.update!(client_declaration_confirmed_at: Time.zone.now)
        go_forward
      else
        render :show
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
