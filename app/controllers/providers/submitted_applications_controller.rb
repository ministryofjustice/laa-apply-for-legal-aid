module Providers
  class SubmittedApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?

    def show
      legal_aid_application # this seems to prevent flickering tests on CircleCI
      @application_proceeding_type = legal_aid_application.lead_application_proceeding_type
    end
  end
end
