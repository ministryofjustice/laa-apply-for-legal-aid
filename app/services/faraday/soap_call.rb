module Faraday
  class SoapError < StandardError; end

  class SoapCall
    attr_reader :url, :type

    def initialize(wsdl_or_url, type)
      @type = type
      raise StandardError, "Unable to parse url" unless parse_url(wsdl_or_url)
    end

    def call(xml_body)
      response = conn.post do |request|
        request.url url
        request.body = xml_body
      end
      response.body
    rescue StandardError => e
      AlertManager.capture_exception(e)
      Rails.logger.error(e.message)
      raise SoapError, e.message
    end

    def headers
      default_headers = {
        SOAPAction: "#POST",
        "Content-Type": "text/xml",
      }
      default_headers[:"x-api-key"] = Rails.configuration.x.ccms_soa.aws_gateway_api_key if type.eql?(:ccms)
      default_headers
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
  end
end
