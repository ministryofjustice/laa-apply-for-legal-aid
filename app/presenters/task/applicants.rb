module Task
  class Applicants < Base
    def path
      Flow::Steps::ProviderStart::ApplicantDetailsStep.path.call(application)
    end
  end
end
