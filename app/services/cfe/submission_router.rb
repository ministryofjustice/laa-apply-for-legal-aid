module CFE
  class SubmissionRouter
    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def call
      if HostEnv.production?
        CFE::SubmissionManager.call(@legal_aid_application.id)
      else
        CFECivil::SubmissionBuilder.call(@legal_aid_application, save_result: true)
      end
    end
  end
end
