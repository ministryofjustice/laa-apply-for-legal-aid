module Citizens
  class LegalAidApplicationsController < BaseController
    def show
      @application_ref = params[:id]
      session[:current_application_ref] = @application_ref
      application = LegalAidApplication.find(@application_ref)
      @applicant = application.applicant

      # TODO: Use an independent token to identify application
      # (e.g. A Devise generated one rather than legal_aid_applicantion.application_ref)

      sign_applicant_in_via_devise(@applicant)

      # TODO: Modify Devise failures to handle failure to authenticate with project styled pages
    end

    private

    def sign_applicant_in_via_devise(applicant)
      scope = Devise::Mapping.find_scope!(applicant)
      sign_in(scope, applicant, event: :authentication)
    end
  end
end
