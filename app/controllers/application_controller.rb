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

    render "pages/service_out_of_hours", status: :temporary_redirect if Setting.out_of_hours?
  end

  def skip_out_of_hours?
    # these are the only pages on the citizen path that are not namespaced as /citizen
    return true if non_standard_citizen_path?

    false
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def update_locale
    I18n.locale = params[:locale] || I18n.default_locale
  rescue I18n::InvalidLocale => e
    Rails.logger.warn "Invalid locale requested: #{e.message}. Falling back to default locale."
    I18n.locale = I18n.default_locale
  end

  def convert_date_params(params)
    # gsub finds ([digit]i) and replaces with _[digit]i
    params.transform_keys! { |key| key.gsub(/\((\di)\)/, '_\\1') }
  end

  def non_standard_citizen_path?
    [
      request.path.include?("auth/true_layer"),
      request.path.include?("error/assessment_already_completed"),
    ].any?
  end
end
