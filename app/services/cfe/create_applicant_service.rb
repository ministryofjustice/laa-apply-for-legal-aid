module CFE
  class CreateApplicantService < BaseService
    def cfe_url_path
      "/assessments/#{@submission.assessment_id}/applicant"
    end

    def request_body
      {
        applicant: {
          date_of_birth: applicant.date_of_birth.strftime('%Y-%m-%d'),
          involvement_type: 'applicant',
          has_partner_opponent: false,
          receives_qualifying_benefit: legal_aid_application.applicant_receives_benefit?
        }
      }.to_json
    end

    private

    def process_response
      @submission.applicant_created!
      true
    end

    def applicant
      legal_aid_application.applicant
    end
  end
end
