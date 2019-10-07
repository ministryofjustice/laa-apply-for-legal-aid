module Providers
  class LegalAidApplicationsController < ProviderBaseController
    include Pagy::Backend
    legal_aid_application_not_required!

    DEFAULT_PAGE_SIZE = 20

    # GET /provider/applications
    def index
      @pagy, @legal_aid_applications = pagy(
        current_provider.firm.legal_aid_applications.latest,
        items: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: [1, 1, 1, 1] # control of how many elements shown in page info
      )
      @initial_sort = { created_at: :desc }
    end

    # POST /provider/applications
    def create
      redirect_to Flow::KeyPoint.path_for(
        journey: :providers,
        key_point: :journey_start
      )
    end
  end
end
