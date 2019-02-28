module Citizens
  class IncomeSummariesController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def show
      legal_aid_application
    end

    def update; end
  end
end
