module Providers
  class LegalAidApplicationsController < ProviderBaseController
    include Pagy::Backend
    legal_aid_application_not_required!

    DEFAULT_PAGE_SIZE = 20

    # GET /provider/applications
    def index
      @pagy, @legal_aid_applications = pagy(
        current_provider.legal_aid_applications.latest,
        items: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: [1, 1, 1, 1] # control of how many elements shown in page info
      )
    end

    # POST /provider/applications
    def create
      @legal_aid_application = LegalAidApplication.create(provider: current_provider)
      go_forward
    end
  end
end
