module Task
  class ProceedingsTypes < Base
    # uri/path to the section start page/form
    def path
      Flow::Steps::ProviderStart::ProceedingsTypesStep.path.call(application)
    end
  end
end
