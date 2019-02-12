module Providers
  class LegalAidApplicationsController < ProviderBaseController
    attr_reader :legal_aid_application
    include Flowable

    # GET /provider/applications
    def index
      # TODO: Add pagination at some point
      @applications = current_provider.legal_aid_applications.latest.limit(10)
    end

    # POST /provider/applications
    def create
      @legal_aid_application = LegalAidApplication.create(provider: current_provider)
      @legal_aid_application.create_other_assets_declaration!
      go_forward
    end
  end
end
