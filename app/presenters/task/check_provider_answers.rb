module Task
  class CheckProviderAnswers < Base
    def path
      Flow::Steps::ProviderStart::CheckProviderAnswersStep.path.call(application)
    end
  end
end
