class BaseController < ApplicationController
  layout 'application'

  def current_legal_aid_application
    return unless session[:current_application_ref].present?
    @current_legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
  end
end
