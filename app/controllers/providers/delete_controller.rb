module Providers
  class DeleteController < ProviderBaseController
    def show
      redirect_to providers_legal_aid_applications_path if @legal_aid_application.discarded?
    end

    def destroy
      @legal_aid_application.discard
      @legal_aid_application.scheduled_mailings.map(&:cancel!)

      redirect_to providers_legal_aid_applications_path
    end
  end
end
