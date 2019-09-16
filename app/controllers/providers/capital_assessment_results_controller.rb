module Providers
  class CapitalAssessmentResultsController < ProviderBaseController
    KNOWN_RESULTS = %w[eligible not_eligible contribution_required].freeze

    def show
      handle_unknown
      @capital_assessment_result = capital_assessment_result
    end

    private

    delegate :capital_assessment_result, to: :legal_aid_application

    def handle_unknown
      return if KNOWN_RESULTS.include?(capital_assessment_result)

      raise "Unknown capital_assessment_result: '#{capital_assessment_result}'"
    end
  end
end
