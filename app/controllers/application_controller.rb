class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do
    render json: {}, status: :not_found
  end
end
