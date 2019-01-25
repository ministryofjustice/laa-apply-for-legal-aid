module Providers
  class RestrictionsController < BaseController
    include ApplicationDependable
    include Flowable

    def index
      legal_aid_application
    end

    def create
      legal_aid_application.update!(legal_aid_application_params)
      go_forward
    end

    private

    def legal_aid_application_params
      params.require(:legal_aid_application).permit(restriction_ids: [])
    end
  end
end
