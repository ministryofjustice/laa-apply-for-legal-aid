module Providers
  class FullEmploymentDetailsController < ProviderBaseController
    def show
      @form = LegalAidApplications::FullEmploymentDetailsForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::FullEmploymentDetailsForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:full_employment_details)
      end
    end
  end
end
