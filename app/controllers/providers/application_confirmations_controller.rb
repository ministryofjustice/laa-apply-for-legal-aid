module Providers
  class ApplicationConfirmationsController < ProviderBaseController
    def show
      legal_aid_application.update!(provider_step: :check_provider_answers)
    end
  end
end
