module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def entra_id
      if auth_data_valid?
        @provider = Provider.from_omniauth(auth_data)
        sign_in_and_redirect @provider, event: :authentication
      else
        flash[:notice] = I18n.t "devise.omniauth_callbacks.unauthorised"
        Rails.logger.error "Couldn't login provider"
        redirect_back(fallback_location: root_path, allow_other_host: false)
      end
    end

    def failure
      flash[:alert] = I18n.t "devise.omniauth_callbacks.failure"
      Rails.logger.error "omniauth error authenticating a user!"
      redirect_to root_path
    end

  protected

    def after_sign_in_path_for(_resource)
      providers_confirm_office_path
    end

  private

    def auth_data
      request.env["omniauth.auth"]
    end

    def auth_data_valid?
      [
        auth_data.extra.raw_info.LAA_ACCOUNTS,
        auth_data.extra.raw_info.USER_NAME,
      ].present?
    rescue StandardError
      false
    end

    def update_provider_details
      ProviderAfterLoginService.call(@provider)
    end
  end
end
