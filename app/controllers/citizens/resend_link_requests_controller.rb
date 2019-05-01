module Citizens
  class ResendLinkRequestsController < ApplicationController
    def show; end

    def update
      ResendLinkRequestMailer.notify(
        secure_application_finder.legal_aid_application
      ).deliver_later
    end

    private

    def secure_application_finder
      @secure_application_finder ||= SecureApplicationFinder.new(params[:id])
    end
  end
end
