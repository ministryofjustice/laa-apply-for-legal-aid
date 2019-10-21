module Providers
  class DelegatedConfirmationController < ProviderBaseController
    def index; end

    private

    def set_legal_aid_application
      legal_aid_application.update!(provider_step: :substantive_applications)
    end
  end
end
