module Providers
  class ApplicationConfirmationsController < ProviderBaseController
    def show; end

    private

    def set_legal_aid_application
      legal_aid_application.update!(provider_step: :check_provider_answers)
    end
  end
end
