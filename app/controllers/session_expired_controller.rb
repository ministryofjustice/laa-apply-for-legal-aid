class SessionExpiredController < ApplicationController
  before_action :update_locale
  def show
    @reason = :timeout unless reason_params[:reason]&.to_sym
  end

  def reason_params
    params.permit(:reason)
  end
end
