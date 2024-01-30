module Faraday
  class SoapCall
    attr_reader :url

    def initialize(wsdl_url)
      raise StandardError, "Unable to parse url" unless parse_url(wsdl_url)
    end

    def call(xml_body)
      response = conn.post do |request|
        request.url url
        request.body = xml_body
      end
      response.body
    end

  private

    def parse_url(input)
      if input.match?(URI::DEFAULT_PARSER.regexp[:ABS_URI])
        # if wsdl_url is a URL return it
        @url = input
      elsif File.file?(input)
        # extract url from wsdl
        File.open(input) do |f|
          doc = Nokogiri::XML(f)
          @url = doc.xpath("//soap:address").attribute("location").value
        end
      else
        false
      end
    end

    def conn
      @conn ||= Faraday.new(url:, headers:)
    end

    def headers
      @headers ||= {
        "x-api-key": Rails.configuration.x.ccms_soa.aws_gateway_api_key,
        SOAPAction: "#POST",
        "Content-Type": "text/xml",
      }
    end
  end
end
