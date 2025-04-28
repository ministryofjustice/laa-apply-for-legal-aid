module Task
  class CheckPassportedAnswers < Base
    def path
      Flow::Steps::ProviderCapital::CheckPassportedAnswersStep.path.call(application)
    end

    def displayed?
      application.passported?
    end
  end
end
