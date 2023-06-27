module CFECivil
  class ObtainStateBenefitTypesService
    def self.call(submission = nil)
      new(submission).call
    end

    attr_reader :submission

    def initialize(submission)
      @submission = submission
    end

    def call
      @response = query_cfe_service
      process_response
    end

    def cfe_url
      File.join(cfe_url_host, cfe_url_path)
    end

  private

    def cfe_url_path
      "/state_benefit_type"
    end

    def query_cfe_service
      conn.get cfe_url_path
    end

    def process_response
      return JSON.parse(@response.body) if @response.status == 200

      raise CFECivil::SubmissionError, "Unable to get State Benefit Types from CFE Server. Status #{@response.status}"
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json;version=#{version}",
      }
    end

    def version
      "6"
    end

    def conn
      @conn ||= Faraday.new(url: cfe_url_host, headers:)
    end

    def cfe_url_host
      Rails.configuration.x.cfe_civil_host
    end
  end
end
