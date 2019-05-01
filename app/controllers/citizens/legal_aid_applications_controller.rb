module Citizens
  class LegalAidApplicationsController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!, only: :index

    # User passes in the Secure Id at the start of the journey. If login succeeds, they
    # are redirected to index where the first page is displayed.
    def show
      return expired if application_error == :expired
      return completed if application.completed_at.present?

      start_applicant_flow
    end

    def index; end

    private

    def expired
      redirect_to citizens_resend_link_request_path(params[:id])
    end

    def completed
      redirect_to error_path(:assessment_already_completed)
    end

    def start_applicant_flow
      sign_out current_provider if provider_signed_in?
      session[:current_application_id] = application.id
      sign_applicant_in_via_devise(application.applicant)
      redirect_to citizens_legal_aid_applications_path
    end

    def sign_applicant_in_via_devise(applicant)
      scope = Devise::Mapping.find_scope!(applicant)
      sign_in(scope, applicant, event: :authentication)
    end

    def application_error
      secure_application_finder.error
    end

    def application
      return if application_error

      @application ||= secure_application_finder.legal_aid_application
    end

    def secure_application_finder
      @secure_application_finder ||= SecureApplicationFinder.new(params[:id])
    end
  end
end
