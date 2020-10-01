module Providers
  class DeleteController < ProviderBaseController
    def show; end

    def destroy
      @legal_aid_application.discard
      redirect_to providers_legal_aid_applications_path
    end
  end
end
