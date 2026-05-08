class SessionExpiredController < ApplicationController
  before_action :update_locale
  def show
    @reason = reason_params[:reason] || "timeout"
  end

  def reason_params
    params.permit(:reason)
  end
end
