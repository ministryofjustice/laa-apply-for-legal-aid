module Providers
  class AuthController < ApplicationController
    def failure
      flash[:error] = I18n.t("devise.omniauth_callbacks.failure", kind: failure_params[:strategy]&.humanize || "Identity manager", reason: failure_params[:message]&.humanize || "Authentication failure!")
      redirect_to error_path(:access_denied)
    end

  private

    def failure_params
      params.permit(:message, :origin, :strategy)
    end
  end
end
