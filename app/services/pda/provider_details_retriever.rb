module PDA
  class ProviderDetailsRetriever
    ApiError = Class.new(StandardError)
    ApiRecordNotFoundError = Class.new(StandardError)
    class Response
      OfficeStruct = Struct.new(:id, :code)

      attr_reader :firm_id,
                  :contact_id,
                  :firm_name,
                  :offices

      def initialize(json_response)
        response = JSON.parse(json_response)
        firm = response["firm"]
        @firm_id = firm["ccmsFirmId"]
        @firm_name = firm["firmName"]
        user = response["user"]
        @contact_id = user["ccmsContactId"]
        @offices = response["officeCodes"].map { |office| OfficeStruct.new(id: office["ccmsProviderOfficeId"], code: office["firmOfficeCode"]) }
      end
    end

    def initialize(username)
      @username = username
    end

    def self.call(username)
      new(username).call
    end

    def call
      body = response.body

      raise_error unless response.status.eql?(200)

      raise_record_not_found_error if body.empty?

      Response.new(body)
    end

  private

    def url
      @url ||= "#{Rails.configuration.x.pda.url}/#{encoded_uri}/provider-offices"
    end

    def encoded_uri
      URI.encode_www_form_component(@username).gsub("+", "%20")
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

    def raise_error
      raise ApiError, "API Call Failed: (#{response.status}) #{response.body}"
    end

    def raise_record_not_found_error
      raise ApiRecordNotFoundError, "Retrieval Failed: (#{response.status}) #{response.body}"
    end
  end
end