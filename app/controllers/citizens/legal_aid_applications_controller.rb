module Citizens
  class LegalAidApplicationsController < BaseController
    include ApplicationFromSession
    # User passes in the Secure Id at the start of the journey. If login succeeds, they
    # are redirected to index where the first page is displayed.
    def show
      secure_id = params[:id]
      @result = LegalAidApplication.find_by_secure_id!(secure_id)

      check_for_expired_url
    rescue ActiveRecord::RecordNotFound
      # TODO: Handle failure
      # TODO: Modify Devise failures to handle failure to authenticate with project styled pages
      render plain: 'Authentication failed'
    end

    def index; end

    private

    def sign_applicant_in_via_devise(applicant)
      scope = Devise::Mapping.find_scope!(applicant)
      sign_in(scope, applicant, event: :authentication)
    end

    def check_for_expired_url
      if @result.error == :expired
        render plain: 'Expired Page - missed url expiry in 7 day window'
      else
        legal_aid_application = @result.value
        if legal_aid_application.completed_at.blank?
          sign_out current_provider if provider_signed_in?

          session[:current_application_id] = legal_aid_application.id

          sign_applicant_in_via_devise(legal_aid_application.applicant)
          redirect_to citizens_legal_aid_applications_path
        else
          render plain: 'Expired Page - completed the application'
        end
      end
    end
  end
end
