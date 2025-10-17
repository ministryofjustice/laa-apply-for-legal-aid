module Admin
  class AdminBaseController < ApplicationController
    before_action :check_vpn_ipaddr, :authenticate_admin_user!, :set_cache_buster, :set_scope
    around_action :switch_locale

  protected

    def check_vpn_ipaddr
      redirect_to error_path(:access_denied) unless ip_addr_authorised?(current_ip_address)
    end

    def current_ip_address
      request.env["HTTP_X_REAL_IP"] || request.env["REMOTE_ADDR"]
    end

    def ip_addr_authorised?(string_ipaddr)
      ip_checker = AuthorizedIpRanges.new
      ip_checker.authorized?(string_ipaddr)
    end

  private

    def set_scope
      @scope = :admin
    end

    def set_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    def switch_locale(&)
      locale = params[:locale] || I18n.default_locale
      I18n.with_locale(locale, &)
    end
  end
end
