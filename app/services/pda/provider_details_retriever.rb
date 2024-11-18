module PDA
  class ProviderDetailsRetriever
    ApiError = Class.new(StandardError)
    ApiRecordNotFoundError = Class.new(StandardError)
    class Result
      OfficeStruct = Struct.new(:id, :code)

      attr_reader :firm_id,
                  :contact_id,
                  :firm_name,
                  :provider_offices,
                  :firm_offices

      def initialize(result)
        firm = result["firm"]
        @firm_id = firm["ccmsFirmId"]
        @firm_name = firm["firmName"]

        user = result["user"]
        @contact_id = user["ccmsContactId"]
        @provider_offices = result["officeCodes"].map { |office| OfficeStruct.new(id: office["ccmsFirmOfficeId"], code: office["firmOfficeCode"]) }
        @firm_offices = result["firm_offices"].map { |office| OfficeStruct.new(id: office["ccmsFirmOfficeId"], code: office["firmOfficeCode"]) }
      end
    end

    def initialize(username)
      @username = username
    end

    def self.call(username)
      new(username).call
    end

    def call
      Result.new(result)
    end

  private

    def result
      firm_id = provider_offices.dig("firm", "firmId")
      firm_offices = provider_firm_offices(firm_id)

      provider_offices.merge("firm_offices" => firm_offices["offices"])
    end

    def provider_offices
      return @provider_offices if @provider_offices

      response = conn.get("/provider-users/#{encoded_username}/provider-offices")
      handle_errors(response)

      @provider_offices = JSON.parse(response.body)
    end

    def provider_firm_offices(firm_id)
      return @provider_firm_offices if @provider_firm_offices

      response = conn.get("/provider-firms/#{firm_id}/provider-offices")
      handle_errors(response)

      @provider_firm_offices = JSON.parse(response.body)
    end

    def encoded_username
      URI.encode_www_form_component(@username).gsub("+", "%20")
    end

    def conn
      @conn ||= Faraday.new(url: Rails.configuration.x.pda.url, headers:)
    end

    def headers
      {
        "accept" => "application/json",
        "X-Authorization" => Rails.configuration.x.pda.auth_key,
      }
    end

    def handle_errors(response)
      raise_error(response) unless response.success?
      raise_record_not_found_error(response) if response.body.empty?
    end

    def raise_error(response)
      raise ApiError, "API Call Failed: (#{response.status}) #{response.body}"
    end

    def raise_record_not_found_error(response)
      raise ApiRecordNotFoundError, "Retrieval Failed: (#{response.status}) #{response.body}"
    end
  end
end
