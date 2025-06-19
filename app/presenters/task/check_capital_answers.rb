module Task
  class CheckCapitalAnswers < Base
    def path
      Flow::Steps::ProviderCapital::CheckCapitalAnswersStep.path.call(application)
    end

    def displayed?
      application.non_passported?
    end
  end
end
