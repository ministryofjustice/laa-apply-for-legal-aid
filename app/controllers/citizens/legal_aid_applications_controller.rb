module Citizens
  class LegalAidApplicationsController < CitizenBaseController
    before_action :authenticate_with_devise, only: :index

    # User passes in the Secure Id at the start of the journey. If login succeeds, they
    # are redirected to index where the first page is displayed.
    def show
      session[:journey_type] = :citizens
      return expired if application_error == :expired

      legal_aid_application.applicant.remember_me!
      legal_aid_application.applicant_enter_means!
      start_applicant_flow
    end

    def index; end

    private

    def authenticate_with_devise
      authenticate_applicant!
    end

    def expired
      redirect_to citizens_resend_link_request_path(params[:id])
    end

    def start_applicant_flow
      sign_out current_provider if provider_signed_in?
      refresh_session
      sign_applicant_in_via_devise(legal_aid_application.applicant)
      redirect_to citizens_legal_aid_applications_path
    end

    def sign_applicant_in_via_devise(applicant)
      scope = Devise::Mapping.find_scope!(applicant)
      sign_in(scope, applicant, event: :authentication)
    end

    def application_error
      secure_application_finder.error
    end

    def legal_aid_application
      return super unless action_name == 'show'
      return if application_error

      @legal_aid_application ||= secure_application_finder.legal_aid_application
    end

    def secure_application_finder
      @secure_application_finder ||= SecureApplicationFinder.new(params[:id])
    end

    def refresh_session
      reset_session
      session[:journey_type] = :citizens
      session[:current_application_id] = legal_aid_application.id
      session[:page_history_id] = SecureRandom.uuid
    end
  end
end
