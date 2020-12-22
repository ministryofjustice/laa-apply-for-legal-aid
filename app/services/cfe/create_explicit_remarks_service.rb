module CFE
  class CreateExplicitRemarksService < BaseService
    delegate :legal_aid_application, to: :submission
    delegate :policy_disregards, to: :legal_aid_application

    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/explicit_remarks"
    end

    def request_body
      {
        explicit_remarks: [
          policy_disregards.as_json
        ]
      }.to_json
    end

    def process_response
      @submission.explicit_remarks_created!
    end
  end
end
