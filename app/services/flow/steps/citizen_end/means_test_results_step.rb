module Flow
  module Steps
    module CitizenEnd
      MeansTestResultsStep = Step.new(
        path: ->(_) { Steps.urls.citizens_means_test_result_path(locale: I18n.locale) },
        forward: nil,
      )
    end
  end
end
