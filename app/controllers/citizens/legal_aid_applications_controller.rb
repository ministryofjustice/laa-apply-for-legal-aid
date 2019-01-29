module Citizens
  class LegalAidApplicationsController < ApplicationController
    include Flowable

    # User passes in the Secure Id at the start of the journey. If login succeeds, they
    # are redirected to index and where the first page is displayed.
    def show
      secure_id = params[:id]
      legal_aid_application = LegalAidApplication.find_by_secure_id!(secure_id)

      session[:current_application_ref] = legal_aid_application.id

      sign_applicant_in_via_devise(legal_aid_application.applicant)
      redirect_to citizens_legal_aid_applications_path
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

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
