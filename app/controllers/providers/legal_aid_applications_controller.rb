module Providers
  class LegalAidApplicationsController < BaseController
    attr_reader :legal_aid_application
    include Providers::Steppable

    # GET /provider/applications
    def index; end

    # POST /provider/applications
    def create
      @legal_aid_application = LegalAidApplication.create
      redirect_to next_step_url
    end
  end
end
