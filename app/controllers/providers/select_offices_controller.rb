module Providers
  class SelectOfficesController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      initialize_page_history
      addresses
      @form = Providers::OfficeForm.new(model: current_provider)
    end

    def update
      @form = Providers::OfficeForm.new(form_params)

      if @form.valid?
        provider_details_updater.call

        # TODO: remove?! This is a temp call while we debug the contract endpoint retrieval and storage
        ProviderContractDetailsWorker.perform_async(form_params[:selected_office_code])

        if provider_details_updater.has_valid_schedules?
          redirect_to stored_location_for(:provider) || your_applications_default_tab_path
        else
          redirect_to providers_invalid_schedules_path
        end
      else
        render :show
      end
    rescue CCMSUser::UserDetails::UserNotFound => e
      Rails.logger.error("#{self.class} - #{e.message}")
      Sentry.capture_message("#{self.class} - #{e.message}")

      redirect_to providers_user_not_founds_path
    end

  private

    def form_params
      merge_with_model(current_provider) do
        next {} unless params[:provider]

        params.expect(provider: [:selected_office_code])
      end
    end

    def addresses
      addresses = []
      current_provider.silas_office_codes.each do |office_code|
        address = PDA::OfficeAddressRetriever.call(office_code)
        addresses << address unless address.nil?
      end
      addresses
    end

    def initialize_page_history
      session[:page_history_id] = SecureRandom.uuid
    end

    def provider_details_updater
      @provider_details_updater ||= if Rails.configuration.x.omniauth_entraid.mock_auth_enabled && HostEnv.not_production?
                                      PDA::MockProviderDetailsUpdater.new(provider, form_params[:selected_office_code])
                                    else
                                      PDA::ProviderDetailsUpdater.new(provider, form_params[:selected_office_code])
                                    end
    end

    def provider
      @provider ||= form_params[:model]
    end
  end
end
