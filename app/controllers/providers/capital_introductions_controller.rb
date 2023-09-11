module Providers
  class CapitalIntroductionsController < ProviderBaseController
    include ApplicantDetailsCheckable

    def show
      if legal_aid_application.passported?
        details_checked! unless details_checked?
        legal_aid_application.provider_enter_means!
      end
    end

    def update
      continue_or_draft
    end
  end
end
