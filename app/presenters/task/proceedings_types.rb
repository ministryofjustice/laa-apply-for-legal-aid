module Task
  class ProceedingsTypes < Base
    def path
      if application.proceedings.any?
        Flow::Steps::ProviderStart::HasOtherProceedingsStep.path.call(application)
      else
        Flow::Steps::ProviderStart::ProceedingsTypesStep.path.call(application)
      end
    end
  end
end
