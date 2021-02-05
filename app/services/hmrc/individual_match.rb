module HMRC
  class IndividualMatch < OAuth
    def initialize(applicant)
      super()
      @applicant = applicant
    end

    def call
      faraday = super
      faraday.headers['correlationId'] = SecureRandom.uuid
      response = faraday.post(hmrc_api_path, @applicant.hmrc_json.to_json)
      JSON.parse(response.body)
    end

    private

    def hmrc_api_path
      '/individuals/matching'
    end

    def accept
      'application/vnd.hmrc.2.0+json'
    end
  end
end
