module Providers
  class CopyCaseConfirmationsController < ProviderBaseController
    def show
      @form = CopyCase::ConfirmationForm.new(model: legal_aid_application)
      @copiable_case = LegalAidApplication.find(session[:copy_case_id])
    end

    def update
      @form = CopyCase::ConfirmationForm.new(form_params)
      @copiable_case = LegalAidApplication.find(session[:copy_case_id])

      # TODO: if they hit backpage we may need to delete proceedings

      render :show unless save_continue_or_draft(@form)
    end

  private

    def form_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(:copy_case_id, :copy_case_confirmation)
      end
    end
  end
end
