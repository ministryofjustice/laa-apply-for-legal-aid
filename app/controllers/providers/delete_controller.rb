module Providers
  class DeleteController < ProviderBaseController
    def show; end

    def destroy
      @legal_aid_application.discard
      @legal_aid_application.scheduled_mailings.map(&:cancel!)

      redirect_to providers_legal_aid_applications_path
    end
  end
end
