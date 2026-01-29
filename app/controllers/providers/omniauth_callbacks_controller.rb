module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def entra_id
      if auth_data_valid?
        @provider = Provider.from_omniauth(auth_data)
        flash[:notice] = I18n.t "devise.omniauth_callbacks.signed_in"
        sign_in_and_redirect @provider, event: :authentication
      else
        flash[:notice] = I18n.t "devise.omniauth_callbacks.unauthorised"
        Rails.logger.error "Couldn't login provider"
        redirect_back_or_to(root_path, allow_other_host: false)
      end
    end

  protected

    def after_sign_in_path_for(_resource)
      providers_select_office_path
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
  end
end
