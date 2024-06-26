module CFECivil
  class ObtainStateBenefitTypesService < BaseService
    def self.call
      new.call
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
  end
end
