module Providers
  class CapitalAssessmentResultsController < ProviderBaseController
    KNOWN_RESULTS = %w[eligible ineligible contribution_required partially_eligible].freeze

    def show
      @cfe_result = legal_aid_application.cfe_result
      handle_unknown
      @details = ManualReviewDetailer.call(legal_aid_application)
      @result_partial = ResultsPanelSelector.call(legal_aid_application)
    end

    def update
      LegalFramework::MeritsTasksService.call(legal_aid_application)
      continue_or_draft
    end

  private

    def handle_unknown
      return if KNOWN_RESULTS.include?(@cfe_result.assessment_result)

      raise "Unknown capital_assessment_result: '#{@cfe_result.assessment_result}'"
    end
  end
end
