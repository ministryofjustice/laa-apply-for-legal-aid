module CFE
  class CreateStateBenefitsService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/state_benefit"
    end

    def request_body
      {

      }.to_json
    end
  end
end
