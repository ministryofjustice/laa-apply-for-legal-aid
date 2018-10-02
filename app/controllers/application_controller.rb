class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: {}, status: :not_found
  end

  protected

  def render_400(errors)
    render json: { errors: ErrorsSerializer.new(errors) }, status: :bad_request
  end
end
