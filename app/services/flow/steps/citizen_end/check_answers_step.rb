module Flow
  module Steps
    module CitizenEnd
      CheckAnswersStep = Step.new(
        path: ->(_) { Steps.urls.citizens_check_answers_path(locale: I18n.locale) },
        forward: :means_test_results,
      )
    end
  end
end
