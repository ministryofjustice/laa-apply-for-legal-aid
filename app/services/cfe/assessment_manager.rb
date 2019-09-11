module CFE
  class AssessmentManager

    def self.call(legal_aid_application_id)
      new(legal_aid_application_id).call
    end

    def initialize(legal_aid_application_id)
      @legal_aid_application_id = legal_aid_application_id
    end

    def call
      assessment = CFE::Assessment.create(legal_aid_applicaiton_id: @legal_aid_application_id)
    end
  end
end
