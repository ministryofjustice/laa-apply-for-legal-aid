module Task
  class HasNationalInsuranceNumbers < Base
    # uri/path to the section start page/form
    def path
      Flow::Steps::ProviderStart::HasNationalInsuranceNumbersStep.path.call(application)
    end
  end
end
