module Citizens
  class MeansTestResultsController < BaseController
    include ApplicationFromSession
    def show
      @applicant = legal_aid_application.applicant
    end
  end
end
