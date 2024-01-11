class ProviderDetailsCWARetriever
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
      @firm_id = response["ccmsFirmId"]
      @contact_id = response["ccmsContactId"]
      @firm_name = response["firmName"]
      @offices = firm_office_contracts(response["firmOfficeContracts"])
    end

  private

    def firm_office_contracts(offices_response)
      offices = []
      offices_response.each do |office|
        offices << OfficeStruct.new(id: office["ccmsFirmOfficeId"], code: office["firmOfficeCode"])
      end
      offices
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
    @url ||= "#{Rails.configuration.x.provider_details_cwa.url}/#{encoded_uri}"
  end

  def encoded_uri
    URI.encode_www_form_component(@username).gsub("+", "%20")
  end

  def headers
    {
      "accept" => "application/json",
      "X-Authorization" => Rails.configuration.x.provider_details_cwa.api_key,
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
  rescue StandardError => e
    raise ApiError, "Provider details error: #{e.class} :: #{e.message}"
  end

  def raise_error
    raise ApiError, "Retrieval Failed: (#{response.status}) #{response.body}"
  end

  def raise_record_not_found_error
    raise ApiRecordNotFoundError, "Retrieval Failed: (#{response.status}) #{response.body}"
  end
end
