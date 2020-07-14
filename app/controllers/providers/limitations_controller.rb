module Providers
  class LimitationsController < ProviderBaseController
    def show
      legal_aid_application.enter_applicant_details! unless legal_aid_application.entering_applicant_details?
    end

    def update
      continue_or_draft
    end
  end
end
