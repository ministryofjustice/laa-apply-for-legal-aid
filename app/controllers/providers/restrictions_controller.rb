module Providers
  class RestrictionsController < ProviderBaseController
    include ApplicationDependable
    include Flowable
    include Draftable

    def index
      legal_aid_application
    end

    def create
      legal_aid_application.update!(legal_aid_application_params)
      continue_or_draft
    end

    private

    def legal_aid_application_params
      params.require(:legal_aid_application).permit(restriction_ids: [])
    end
  end
end
