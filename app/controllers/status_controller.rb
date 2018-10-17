class StatusController < ApiController
  def index
    render json: { status: 'ok' }
  end
end
