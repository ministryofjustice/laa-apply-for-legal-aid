module Providers
  class PropertyValuesController < ProviderBaseController
    def show
      @form = LegalAidApplications::PropertyValueForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PropertyValueForm.new(edit_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def edit_params
      merge_with_model(legal_aid_application, journey: :providers) do
        params.require(:legal_aid_application).permit(:property_value)
      end
    end
  end
end
