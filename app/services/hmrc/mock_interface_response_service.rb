module HMRC
  class MockInterfaceResponseService
    MATCHED = {
      single_employment: { first_name: 'Langley', last_name: 'Yorke', nino: 'MN212451D', dob: '1992-07-22' },
      multiple_employments: { first_name: 'Ida', last_name: 'Paisley', nino: 'OE726113A', dob: '1987-11-24' },
      employment_tax_credits: { first_name: 'Oakley', last_name: 'Weller', nino: 'RE476107D', dob: '1959-02-22' },
      weekly_employment: { first_name: 'Tom', last_name: 'Waits', nino: 'AA268555C', dob: '1955-05-15' },
      four_weekly_employment: { first_name: 'Jeremy', last_name: 'Irons', nino: 'BB313661B', dob: '1966-06-16' },
      monthly_employment: { first_name: 'Stevie', last_name: 'Nicks', nino: 'CC414771C', dob: '1977-07-17' }
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
      @hmrc_response.update!(response: return_json, submission_id: @submission_id)
    end

    private

    def return_json
      applicant_matched? || unknown_response
    end

    def applicant_matched?
      applicant_found = MATCHED.key({ first_name: first_name, last_name: last_name, nino: national_insurance_number, dob: date_of_birth.strftime('%Y-%m-%d') })
      # return send(collate_response(applicant_found)) unless applicant_found.nil?
      return collate_response(applicant_found) unless applicant_found.nil?
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

    # def single_employment
    #   json_file = File.read('app/services/hmrc/mock_data/single_employment.json')
    #   JSON.parse(json_file.gsub('@submission_id', @submission_id).gsub('@use_case_name', "use_case_#{@hmrc_response.use_case}"))
    # end
    #
    # def employment_tax_credits
    #   json_file = File.read('app/services/hmrc/mock_data/employment_tax_credits.json')
    #   JSON.parse(json_file.gsub('@submission_id', @submission_id).gsub('@use_case_name', "use_case_#{@hmrc_response.use_case}"))
    # end

    def collate_response(scenario)
      json_file = File.read("app/services/hmrc/mock_data/#{scenario}.json")
      JSON.parse(json_file.gsub('@submission_id', @submission_id).gsub('@use_case_name', "use_case_#{@hmrc_response.use_case}"))
    end
  end
end
