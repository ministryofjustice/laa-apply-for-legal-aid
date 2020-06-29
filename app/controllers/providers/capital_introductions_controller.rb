module Providers
  class CapitalIntroductionsController < ProviderBaseController
    def show
      legal_aid_application.provider_enter_means!
    end

    def update
      continue_or_draft
    end
  end
end
