module Providers
  class CapitalIncomeAssessmentResultsController < ProviderBaseController
    KNOWN_RESULTS = %w[eligible ineligible contribution_required partially_eligible].freeze

    def show
      @cfe_result = legal_aid_application.cfe_result
      handle_unknown
      @details = ManualReviewDetailer.call(legal_aid_application)
      @result_partial = ResultsPanelSelector.call(legal_aid_application)
      @ineligible_reasons = ineligible_reasons if @cfe_result.assessment_result == "ineligible"
    end

    def update
      continue_or_draft
    end

  private

    def handle_unknown
      return if KNOWN_RESULTS.include?(@cfe_result.assessment_result)

      raise "Unknown capital_income_assessment_result: '#{@cfe_result.assessment_result}'"
    end

    def ineligible_reasons
      return "" unless @cfe_result.assessment_result == "ineligible"
      return ineligible_reasons_array.first if ineligible_reasons_array.length == 1

      ineligible_reasons = ":<br><br>"
      ineligible_reasons_array.each { |reason| ineligible_reasons += "-#{reason}<br>" }
      ineligible_reasons
    end

    def ineligible_reasons_array
      return [] unless @cfe_result.assessment_result == "ineligible"

      ineligible_reasons_array = []
      ineligible_reasons_array << "gross income" if ineligible_gross_income?
      ineligible_reasons_array << "disposable income" if ineligible_disposable_income?
      ineligible_reasons_array << "disposable capital" if ineligible_disposable_capital?
      ineligible_reasons_array
    end

    def ineligible_gross_income?
      return false unless @cfe_result.assessment_result == "ineligible"
      return false unless (@cfe_result.gross_income_results - %w[ineligible]).empty?

      true
    end

    def ineligible_disposable_income?
      return false unless @cfe_result.assessment_result == "ineligible"
      return false unless (@cfe_result.disposable_income_results - %w[ineligible]).empty?

      true
    end

    def ineligible_disposable_capital?
      return false unless @cfe_result.assessment_result == "ineligible"
      return false unless (@cfe_result.capital_results - %w[ineligible]).empty?

      true
    end
  end
end
