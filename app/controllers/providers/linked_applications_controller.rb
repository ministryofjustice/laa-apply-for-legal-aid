module Providers
  class LinkedApplicationsController < ProviderBaseController
    def show
      @form = LegalAidApplications::LinkedApplicationForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::LinkedApplicationForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def form_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(:linked_application_ref, :link_type_code, :legal_aid_application, :has_linked_application)
      end
    end
  end
end
