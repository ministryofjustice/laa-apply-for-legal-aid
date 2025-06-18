module Task
  class CheckIncomeAnswers < Base
    def path
      Flow::Steps::ProviderCapital::CheckIncomeAnswersStep.path.call(application)
    end
  end
end
