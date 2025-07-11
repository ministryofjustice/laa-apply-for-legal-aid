module Providers
  class AuthController < ApplicationController
    def failure(reason: "Authentication failure!")
      # set_flash_message(:error, :failure, kind: "EntraID", reason:)
      flash[:error] = I18n.t("devise.omniauth_callbacks.failure", kind: "EntraID", reason:)
      redirect_to error_path(:access_denied)
    end
  end
end
