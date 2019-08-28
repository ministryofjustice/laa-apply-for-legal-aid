module Citizens
  class MeansTestResultsController < CitizenBaseController
    allow_view_when_complete

    def show
      @applicant = legal_aid_application.applicant
    end
  end
end
