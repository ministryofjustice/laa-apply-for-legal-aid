module Citizens
  class ResendLinkRequestsController < ApplicationController
    before_action :update_locale
    def show; end

    def update
      ResendLinkRequestMailer.notify(
        legal_aid_application.application_ref,
        legal_aid_application.applicant.email_address,
        application_url,
        legal_aid_application.applicant.full_name
      ).deliver_later!
    end

    private

    def legal_aid_application
      @legal_aid_application ||= SecureApplicationFinder.new(params[:id]).legal_aid_application
    end

    def application_url
      @application_url ||= citizens_legal_aid_application_url(secure_id)
    end

    def secure_id
      legal_aid_application.generate_secure_id
    end
  end
end
