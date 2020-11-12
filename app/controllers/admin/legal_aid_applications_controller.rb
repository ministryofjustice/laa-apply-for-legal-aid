module Admin
  class LegalAidApplicationsController < AdminBaseController
    include Pagy::Backend

    DEFAULT_PAGE_SIZE = 10

    def index
      @pagy, @applications = pagy(
        LegalAidApplication.latest,
        items: params.fetch(:page_size, DEFAULT_PAGE_SIZE),
        size: [1, 1, 1, 1]
      )
    end

    def create_test_applications
      TestApplicationCreationService.call
      redirect_to action: :index
    end

    def destroy_all
      raise 'Legal Aid Application Destroy All action disabled' unless destroy_enabled?

      LegalAidApplication.destroy_all
      redirect_to action: :index
    end

    def destroy
      raise 'Legal Aid Application Destroy action disabled' unless destroy_enabled?

      legal_aid_application.destroy
      redirect_to action: :index
    end

    protected

    def create_test_applications_enabled?
      Rails.configuration.x.admin_portal.allow_create_test_applications
    end

    # Note this action uses the mock_saml setting to determine if it should be enabled
    def destroy_enabled?
      Rails.configuration.x.admin_portal.allow_reset
    end
    helper_method :destroy_enabled?, :create_test_applications_enabled?

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(params[:id])
    end
  end
end
