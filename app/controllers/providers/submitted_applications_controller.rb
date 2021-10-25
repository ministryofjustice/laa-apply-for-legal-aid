module Providers
  class SubmittedApplicationsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?

    def show
      puts ">>>>>>>>>>>> legal aid application  #{legal_aid_application.id} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
      @application_proceeding_type = legal_aid_application.lead_application_proceeding_type
    end
  end
end
