module Citizens
  class IncomeSummaryController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def index
      legal_aid_application
    end
  end
end
