module Admin
  class LegalAidApplicationsController < ApplicationController
    before_action :authenticate_admin_user!
    def index
      @applications = LegalAidApplication.latest.limit(25)
    end

    def destroy_all
      raise 'Legal Aid Application Destroy All action disabled' unless destroy_enabled?

      LegalAidApplication.destroy_all
      Applicant.destroy_all
      redirect_to action: :index
    end

    def destroy
      raise 'Legal Aid Application Destroy action disabled' unless destroy_enabled?

      applicant_id = LegalAidApplication.find(legal_aid_application_id).applicant_id

      if applicant_id
        Applicant.destroy(applicant_id)
      else
        LegalAidApplication.destroy(legal_aid_application_id)
      end

      redirect_to action: :index
    end

    protected

    # Note this action uses the mock_saml setting to determine if it should be enabled
    def destroy_enabled?
      Rails.configuration.x.admin_portal.allow_reset
    end
    helper_method :destroy_enabled?

    private

    def legal_aid_application_id
      params[:legal_aid_application_id]
    end
  end
end
