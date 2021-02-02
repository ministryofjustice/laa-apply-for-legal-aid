class ErrorsController < ApplicationController
  before_action :update_locale
  def show
    @error = error_param
  end

  def page_not_found
    update_locale
    redirect_to error_path(:page_not_found, default_url_options)
  end

  private

  def error_param
    params.require(:id)
  end
end
