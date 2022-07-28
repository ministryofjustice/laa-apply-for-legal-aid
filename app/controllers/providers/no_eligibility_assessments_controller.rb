module Providers
  class NoEligibilityAssessmentsController < ProviderBaseController
    def show
      legal_aid_application.provider_enter_merits! unless legal_aid_application.provider_entering_merits?
      @result_partial = ResultsPanelSelector.call(legal_aid_application)
    end

    def update
      continue_or_draft
    end
  end
end
