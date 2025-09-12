class ApplicationController < ActionController::Base
  layout "application"
  before_action :out_of_hours_redirect

  include Backable
  include HomePathHelper
  include YourApplicationsHelper

  helper_method :home_path

private

  def out_of_hours_redirect
    return if skip_out_of_hours?

    render "pages/service_out_of_hours", status: :service_unavailable if Setting.out_of_hours?
  end

  def skip_out_of_hours?
    # this is the only page on the citizen path that cannot be namespaced as /citizen
    return true if request.path.include?("auth/true_layer")

    false
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def update_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def convert_date_params(params)
    # gsub finds ([digit]i) and replaces with _[digit]i
    params.transform_keys! { |key| key.gsub(/\((\di)\)/, '_\\1') }
  end
end
