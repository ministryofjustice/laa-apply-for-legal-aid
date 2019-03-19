module Providers
  class StartMeritsAssessmentsController < ProviderBaseController
    before_action :authorize_legal_aid_application

    def show; end

    def update
      continue_or_draft
    end

    private

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
