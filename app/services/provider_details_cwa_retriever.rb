class ProviderDetailsCWARetriever
  def initialize(username)
    @username = username
  end

  def call
    request.body
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
