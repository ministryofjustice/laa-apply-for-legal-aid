# This controller is called by the application config exceptions_app.
# idea taken from  https://dev.to/ayushn21/custom-error-pages-in-rails-4i43
#
# We may need to consider handling ActionDispatch::Http::MimeNegotiation::InvalidType
# as mentioned here https://guides.rubyonrails.org/configuring.html#config-exceptions-app
#
class ErrorsController < ApplicationController
  skip_before_action :authenticate_provider!

  before_action :update_locale, :set_error_name
  def show
    respond_to do |format|
      format.html { render :show, status: status_for(@error_name) }
      format.all { render plain: "Not found", status: :not_found }
    end
  end

private

  def set_error_name
    return @error_name if @error_name

    @error_name = error_name_from_status_or_params
    @error_name = :page_not_found unless supported_errors.key?(@error_name&.to_sym)
    @error_name
  end

  def error_name_from_status_or_params
    case status_code
    when 404
      :page_not_found
    when (500..599)
      :internal_server_error
    else
      error_param[:id]
    end
  end

  def status_code
    exception = request.env["action_dispatch.exception"]
    return unless exception

    @status_code = exception.try(:status_code) || ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
  end

  def status_for(error_name)
    supported_errors.fetch(error_name.to_sym, :not_found)
  end

  def supported_errors
    {
      page_not_found: :not_found,
      access_denied: :forbidden,
      assessment_already_completed: :ok,
      internal_server_error: :internal_server_error,
      benefit_checker_down: :internal_server_error,
    }
  end

  def error_param
    params.permit(:id)
  end
end
