module Providers
  class SelectOfficesController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      initialize_page_history
      @form = Providers::OfficeForm.new(model: current_provider)
    end

    def update
      @form = Providers::OfficeForm.new(form_params)

      if @form.valid?
        provider = form_params[:model]

        PDA::ProviderDetails.call(provider, form_params[:selected_office_code])

        # TODO: remove?! This is a temp call while we debug the contract endpoint retrieval and storage
        ProviderContractDetailsWorker.perform_async(form_params[:selected_office_code])

        redirect_to home_path
      else
        render :show
      end
    rescue PDA::ProviderDetails::ValidDetailsNotFound => e
      flash.now[:error] = e.message
      render :show
    end

  private

    def form_params
      merge_with_model(current_provider) do
        next {} unless params[:provider]

        params.expect(provider: [:selected_office_code])
      end
    end

    def initialize_page_history
      session[:page_history_id] = SecureRandom.uuid
    end
  end
end
