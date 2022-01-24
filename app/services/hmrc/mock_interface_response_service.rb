module HMRC
  class MockInterfaceResponseService
    MATCHED = {
      single_employment: { first_name: 'Langley', last_name: 'Yorke', nino: 'MN212451D', dob: '1992-07-22' }
    }.freeze

    def self.call(*args)
      new(*args).call
    end

    attr_reader :application

    delegate :applicant, to: :application, allow_nil: true
    delegate :first_name, :last_name, :national_insurance_number, :date_of_birth, to: :applicant, allow_nil: true

    def initialize(hmrc_response)
      @hmrc_response = hmrc_response
      @application = @hmrc_response.legal_aid_application
      @submission_id = SecureRandom.uuid
    end

    def call
      @hmrc_response.update!(response: return_json.to_json, submission_id: @submission_id)
    end

    private

    def return_json
      applicant_matched? || unknown_response
    end

    def applicant_matched?
      applicant_found = MATCHED.key({ first_name: first_name, last_name: last_name, nino: national_insurance_number, dob: date_of_birth.strftime('%Y-%m-%d') })
      return send(applicant_found) unless applicant_found.nil?
    end

    def unknown_response
      {
        submission: @submission_id,
        status: 'failed',
        data: [
          {
            correlation_id: @submission_id,
            use_case: "use_case_#{@hmrc_response.use_case}"
          },
          {
            error: 'submitted client details could not be found in HMRC service'
          }
        ]
      }
    end

    def single_employment
      json_file = File.read('app/services/hmrc/mock_data/single_employment.json')
      JSON.parse(json_file.gsub('@submission_id', @submission_id).gsub('@use_case_name', "use_case_#{@hmrc_response.use_case}"))
    end
  end
end
