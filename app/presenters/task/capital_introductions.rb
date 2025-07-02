module Task
  class CapitalIntroductions < Base
    def path
      Flow::Steps::ProviderCapital::IntroductionsStep.path.call(application)
    end
  end
end
