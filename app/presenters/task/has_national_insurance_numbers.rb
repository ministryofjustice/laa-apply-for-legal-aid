module Task
  class HasNationalInsuranceNumbers < Base
    def path
      Flow::Steps::ProviderStart::HasNationalInsuranceNumbersStep.path.call(application)
    end
  end
end
