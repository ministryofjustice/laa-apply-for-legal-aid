module Citizens
  class LegalAidApplicationsController < BaseController
    def show
      @application_ref = params[:id]
      session[:current_application_ref] = @application_ref
      application = LegalAidApplication.find(@application_ref)
      @applicant = application&.applicant
      # TODO: redirect the user to an error page if the minimum
      # amount of details are not set to show the page
    end
  end
end
