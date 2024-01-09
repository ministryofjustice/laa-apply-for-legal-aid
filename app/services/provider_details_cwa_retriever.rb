class ProviderDetailsCWARetriever
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
        offices << OfficeStruct.new(id: office["firmOfficeId"], code: office["firmOfficeCode"])
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
    body = request.body
    return body if body.empty?

    Response.new(body)
  end

private

  def url
    @url ||= "#{Rails.configuration.x.provider_details_cwa.url}/#{@username}"
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

  def request
    conn.get url
  end
end
