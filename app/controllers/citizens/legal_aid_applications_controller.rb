module Citizens
  class LegalAidApplicationsController < BaseController
    def show
      secure_id = params[:id]
      legal_aid_application = LegalAidApplication.find_by_secure_id(secure_id)
      session[:current_application_ref] = legal_aid_application.id
      @applicant = legal_aid_application&.applicant

      # TODO: Use an independent token to identify application
      # (e.g. A Devise generated one rather than legal_aid_applicantion.application_ref)

      sign_applicant_in_via_devise(@applicant)

    rescue ActiveRecord::RecordNotFound
      # TODO: Handle failure
      # TODO: Modify Devise failures to handle failure to authenticate with project styled pages
      render plain: "Authentication failed"
    end

    private

    def sign_applicant_in_via_devise(applicant)
      scope = Devise::Mapping.find_scope!(applicant)
      sign_in(scope, applicant, event: :authentication)

    end
  end
end
