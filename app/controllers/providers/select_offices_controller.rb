module Providers
  class SelectOfficesController < ProviderBaseController
    legal_aid_application_not_required!
    # helper_method :firm

    def show
      @form = Providers::OfficeForm.new(model: current_provider)
    end

    def update
      @form = Providers::OfficeForm.new(form_params)

      if @form.valid?
        # office = current_provider.offices.find_or_create_by!(code: @form.selected_office_code)
        # TODO: This is a temp call while we debug the contract endpoint retrieval and storage
        # ProviderContractDetailsWorker.perform_async(Office.find(form_params[:selected_office_code]))
        PDA::ProviderDetails.call(form_params[:selected_office_code])
        redirect_to home_path
      else
        render :show
      end
    end

  private

    # def firm
    #   current_provider.firm
    # end

    def form_params
      merge_with_model(current_provider) do
        params.expect(provider: [:selected_office_code])
      end
    end
  end
end
