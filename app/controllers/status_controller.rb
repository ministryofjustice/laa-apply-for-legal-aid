class StatusController < ApplicationController
  def index
    result = Healthcheck.perform
    render json: { status: 'ok', healthcheck: result }
  end
end
