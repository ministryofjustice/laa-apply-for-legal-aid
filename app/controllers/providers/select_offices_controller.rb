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
        # office = current_provider.offices.find_or_create_by!(code: @form.selected_office_code)
        # TODO: This is a temp call while we debug the contract endpoint retrieval and storage
        # ProviderContractDetailsWorker.perform_async(Office.find(form_params[:selected_office_code]))
        pda = PDA::ProviderDetails.new(form_params[:selected_office_code])
        pda.call
        if pda.has_valid_schedules?
          current_provider.update!(firm: pda.firm)
          redirect_to home_path
        else
          redirect_to providers_invalid_schedules_path
        end
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
        params.expect(provider: [:selected_office_code])
      end
    end

    def initialize_page_history
      session[:page_history_id] = SecureRandom.uuid
    end
  end
end
