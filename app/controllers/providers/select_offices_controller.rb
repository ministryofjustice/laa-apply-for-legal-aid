module Providers
  class SelectOfficesController < ProviderBaseController
    include OfficeAddressHandling

    legal_aid_application_not_required!

    OfficeAddressCollectionItem = Struct.new(:code, :address)

    def show
      initialize_page_history
      @office_addresses = office_addresses
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
        @office_addresses = office_addresses
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

    def silas_office_codes
      @silas_office_codes ||= current_provider.silas_office_codes
    end

    def office_addresses
      @office_addresses ||= silas_office_codes.map do |silas_office_code|
        office_address_struct = pda_addresses.find { |pda_address| pda_address.code == silas_office_code }
        office_address = if office_address_struct
                           one_line_office_address(office_address_struct)
                         else
                           I18n.t("errors.office_address.not_found")
                         end
        OfficeAddressCollectionItem.new(code: silas_office_code, address: office_address)
      end
    end

    def pda_addresses
      @pda_addresses ||= PDA::OfficesAddressesRetriever.call(silas_office_codes)
    rescue StandardError
      []
    end
  end
end
