module Task
  class MakeLink < Base
    def path
      Flow::Steps::LinkedApplications::MakeLinkStep.path.call(application)
    end
  end
end
