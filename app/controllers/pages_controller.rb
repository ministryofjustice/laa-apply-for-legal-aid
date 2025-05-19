class PagesController < ApplicationController
  def servicedown
    respond_to do |format|
      format.html do
        redirect_to "https://laa-holding-page-production.apps.live.cloud-platform.service.justice.gov.uk/", allow_other_host: true
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
end
