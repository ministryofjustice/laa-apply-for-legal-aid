module PDA
  class CurrentContracts
    def initialize(office_code)
      @office_code = office_code
    end

    def self.call(office_code)
      new(office_code).call
    end

    def call
      body = response.body

      # TODO: 16 September 2024 Colin Bruce - Replace once data has been analysed and responses can be stored correctly
      # TEMP: Create TempContractData model and store it
      case response.status
      when 204
        log_record_not_found_error
      when 200
        create_temp_contract_data(JSON.parse(body))
        JSON.parse(body)
      else
        log_error
      end
    end

  private

    def url
      @url ||= "#{Rails.configuration.x.pda.url}/provider-offices/#{@office_code}/office-contract-details"
    end

    def headers
      {
        "accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.pda.auth_key,
      }
    end

    def conn
      @conn ||= Faraday.new(url:, headers:)
    end

    def response
      @response ||= query_api
    end

    def query_api
      conn.get url
    end

    def log_error
      message = "API Call Failed: (#{response.status}) #{response.body}"
      create_temp_contract_data({ error: message })
    end

    def log_record_not_found_error
      message = "Retrieval for #{@office_code} failed, no data found: (#{response.status}) #{response.body}"
      create_temp_contract_data({ error: message })
    end

    def create_temp_contract_data(json)
      success = !json.stringify_keys.keys[0].eql?("error")
      TempContractData.create!(success:, office_code: @office_code, response: json)
    end
  end
end
