class ApplicationController < ActionController::Base
  layout 'application'
  include Backable
  include OmniauthPathHelper
  helper_method :omniauth_login_start_path

  # See also catch all route at end of config/routes.rb
  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  private

  def page_not_found
    update_locale
    redirect_to error_path(:page_not_found, default_url_options)
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
