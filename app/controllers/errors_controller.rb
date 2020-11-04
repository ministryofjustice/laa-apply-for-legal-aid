class ErrorsController < ApplicationController
  def show; end

  def page_not_found
    update_locale
    redirect_to error_path(:page_not_found, default_url_options)
  end
end
