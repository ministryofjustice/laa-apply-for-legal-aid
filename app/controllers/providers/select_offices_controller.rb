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
        # TODO: This is a temp call while we debug the contract endpoint retrieval and storage
        ProviderContractDetailsWorker.perform_async(Office.find(form_params[:selected_office_id]).code)
        PDA::SchedulesCreator.call(Office.find(form_params[:selected_office_id]).code)
        redirect_to home_path
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

        params.expect(provider: [:selected_office_id])
      end
    end
  end
end
