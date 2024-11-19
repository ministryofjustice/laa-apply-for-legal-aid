# This controller is called by the application config exceptions_app.
# idea taken from  https://dev.to/ayushn21/custom-error-pages-in-rails-4i43
#
# We may need to consider handling ActionDispatch::Http::MimeNegotiation::InvalidType
# as mentioned here https://guides.rubyonrails.org/configuring.html#config-exceptions-app
#
class ErrorsController < ApplicationController
  before_action :update_locale
  def show
    render :show, status: status_for(error)
  end

private

  def error
    return @error if @error

    @error = error_param[:id]
    @error = :page_not_found unless supported_errors.key?(@error&.to_sym)
    @error
  end

  def status_for(error)
    supported_errors.fetch(error.to_sym, :not_found)
  end

  def supported_errors
    {
      page_not_found: :not_found,
      access_denied: :ok,
      assessment_already_completed: :ok,
    }
  end

  def error_param
    params.permit(:id)
  end
end
