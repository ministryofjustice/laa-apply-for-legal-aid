module Flow
  module Flows
    class CitizenEnd
      STEPS = {
        check_answers: Steps::CitizenEnd::CheckAnswersStep,
        means_test_results: Steps::CitizenEnd::MeansTestResultsStep,
      }.freeze
    end
  end
end
