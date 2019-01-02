module Providers
  class LegalAidApplicationsController < BaseController
    attr_reader :legal_aid_application
    include Steppable

    # GET /provider/applications
    def index; end

    # POST /provider/applications
    def create
      @legal_aid_application = LegalAidApplication.create
      @legal_aid_application.create_other_assets_declaration!
      redirect_to next_step_url
    end
  end
end
