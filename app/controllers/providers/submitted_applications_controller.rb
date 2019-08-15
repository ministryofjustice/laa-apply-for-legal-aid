module Providers
  class SubmittedApplicationsController < ProviderBaseController
    authorize_with_policy :show_submitted_application?

    def show; end
  end
end
