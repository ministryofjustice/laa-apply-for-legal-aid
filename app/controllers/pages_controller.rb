class PagesController < ApplicationController
  def servicedown
    respond_to do |format|
      format.html do
        render :servicedown
      end
      format.json do
        render  json:
                [{ error: "Service temporarily unavailable" }],
                status: :service_unavailable
      end
      format.js do
        render  json:
                [{ error: "Service temporarily unavailable" }],
                status: :service_unavailable
      end
      format.all do
        render  plain: "error: Service temporarily unavailable",
                status: :service_unavailable
      end
    end
  end

  def service_out_of_hours; end
end
