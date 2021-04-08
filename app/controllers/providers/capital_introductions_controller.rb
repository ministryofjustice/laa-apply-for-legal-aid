module Providers
  class CapitalIntroductionsController < ProviderBaseController
    def show
      details_checked! unless details_checked?
      legal_aid_application.provider_enter_means!
    end

    def update
      continue_or_draft
    end

    private

    def details_checked!
      legal_aid_application.applicant_details_checked!
    end

    def details_checked?
      legal_aid_application.applicant_details_checked?
    end
  end
end
