module Providers
  class RestrictionsController < ApplicationController
    include Steppable
    include Providers::ApplicationDependable
    include SaveAsDraftable

    def index
      legal_aid_application
    end

    def create
      legal_aid_application.update!(legal_aid_application_params)
      continue_or_save_draft
    end

    private

    def legal_aid_application_params
      params.require(:legal_aid_application).permit(restriction_ids: [])
    end
  end
end
