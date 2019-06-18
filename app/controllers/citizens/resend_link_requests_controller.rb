module Citizens
  class ResendLinkRequestsController < ApplicationController
    def show; end

    def update
      ResendLinkRequestMailer.notify(
        legal_aid_application,
        legal_aid_application.applicant
      ).deliver_later!
    end

    private

    def legal_aid_application
      @legal_aid_application ||= SecureApplicationFinder.new(params[:id]).legal_aid_application
    end
  end
end
