module Citizens
  class LegalAidApplicationsController < BaseController
    include ApplicationFromSession
    # User passes in the Secure Id at the start of the journey. If login succeeds, they
    # are redirected to index where the first page is displayed.
    def show
      return expired if find_legal_aid_application.error == :expired
      return completed if application.completed_at.present?

      start_applicant_flow
    end

    def index; end

    private

    def expired
      redirect_to error_path(:link_expired)
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

    def application
      find_legal_aid_application.value
    end

    def find_legal_aid_application
      @find_legal_aid_application ||= LegalAidApplication.find_by_secure_id!(params[:id])
    end
  end
end
