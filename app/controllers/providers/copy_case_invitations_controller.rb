module Providers
  class CopyCaseInvitationsController < ProviderBaseController
    def show
      @form = CopyCase::InvitationForm.new(model: legal_aid_application)
    end

    def update
      @form = CopyCase::InvitationForm.new(form_params)

      render :show unless save_continue_or_draft(@form)
    end

  private

    def form_params
      merge_with_model(legal_aid_application) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:copy_case)
      end
    end
  end
end
