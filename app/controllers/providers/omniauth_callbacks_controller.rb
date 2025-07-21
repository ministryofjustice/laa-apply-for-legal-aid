module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def entra_id
      @provider = Provider.from_omniauth(request.env["omniauth.auth"])

      if @provider&.persisted?
        flash[:notice] = I18n.t "devise.sessions.signed_in"
        sign_in_and_redirect @provider, event: :authentication
        update_provider_details
      else
        flash[:notice] = I18n.t "devise.omniauth_callbacks.unauthorised"
        Rails.logger.error "Couldn't login user"
        redirect_back(fallback_location: unauthenticated_root_path, allow_other_host: false)
      end
    end

    def failure
      flash[:alert] = I18n.t "devise.omniauth_callbacks.failure"
      Rails.logger.error "omniauth error authenticating a user!"
      redirect_to unauthenticated_root_path
    end

  protected

    def update_provider_details
      ProviderAfterLoginService.call(@provider)
    end

    def after_sign_in_path_for(resource)
      providers_confirm_office_path(resource)
    end
  end
end
