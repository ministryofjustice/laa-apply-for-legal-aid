module Providers
  class NoEligibilityAssessmentsController < ProviderBaseController

    def show
      @details = ManualReviewDetailer.call(legal_aid_application)
      @result_partial = ResultsPanelSelector.call(legal_aid_application)
    end


    def update
      continue_or_draft
    end
  end
end
