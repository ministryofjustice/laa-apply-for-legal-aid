module Task
  class Partner < Base
    def path
      Flow::Steps::Partner::ClientHasPartnersStep.path.call(application)
    end
  end
end
