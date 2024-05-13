module Flow
  module Flows
    class CitizenEnd < FlowSteps
      STEPS = {
        check_answers: Steps::CitizenEnd::CheckAnswersStep,
        means_test_results: {
          path: ->(_) { urls.citizens_means_test_result_path(locale: I18n.locale) },
          forward: nil,
        },
      }.freeze
    end
  end
end
