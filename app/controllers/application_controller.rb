class ApplicationController < ActionController::Base
  layout "application"

  include Backable
  include YourApplicationsHelper

private

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
