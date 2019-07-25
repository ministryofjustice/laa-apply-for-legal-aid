module Providers
  class SelectOfficesController < ProviderBaseController
    legal_aid_application_not_required!
    helper_method :firm

    def show
      @form = Providers::OfficeForm.new(model: current_provider)
    end

    def update
      @form = Providers::OfficeForm.new(form_params)

      if @form.save
        redirect_to providers_legal_aid_applications_path
      else
        render :show
      end
    end

    private

    def firm
      current_provider.firm
    end

    def form_params
      merge_with_model(current_provider) do
        next {} unless params[:provider]

        params.require(:provider).permit(:selected_office_id)
      end
    end
  end
end
