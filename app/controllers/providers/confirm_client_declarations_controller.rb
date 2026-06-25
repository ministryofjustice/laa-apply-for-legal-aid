module Providers
  class ConfirmClientDeclarationsController < ProviderBaseController
    def show
      legal_aid_application.confirm_review_and_print_application! unless legal_aid_application.confirming_reviewing_and_printing_application?
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

        params.expect(legal_aid_application: [:client_declaration_confirmed])
      end
    end
  end
end
