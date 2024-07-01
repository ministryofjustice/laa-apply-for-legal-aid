module CCMS
  module Requestors
    class BaseRequestor
      NAMESPACES = {
        "xmlns:bill" => "http://legalservices.gov.uk/CCMS/Finance/Payables/1.0/BillingBIO",
        "xmlns:casebim" => "http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM",
        "xmlns:casebio" => "http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIO",
        "xmlns:clientbio" => "http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIO",
        "xmlns:clientbim" => "http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM",
        "xmlns:common" => "http://legalservices.gov.uk/Enterprise/Common/1.0/Common",
        "xmlns:hdr" => "http://legalservices.gov.uk/Enterprise/Common/1.0/Header",
        "xmlns:refdatabim" => "http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIM",
        "xmlns:refdatabio" => "http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIO",
        "xmlns:secext" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd",
        "xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:utility" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd",
        "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      }.freeze

      attr_reader :namespaces

      def initialize
        @namespaces = NAMESPACES
      end

      class << self
        attr_reader :wsdl

        def wsdl_from(filename)
          @wsdl = filename
        end
      end

      def formatted_xml
        result = ""
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        formatter.write(REXML::Document.new(replace_special_characters(request_xml)), result)
        result
      end

      def transaction_request_id
        @transaction_request_id ||= Time.current.strftime("%Y%m%d%H%M%S%6N") + rand.to_s[2..8]
      end

    private

      def soap_envelope(namespaces)
        Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.__send__(:"soap:Envelope", namespaces) do
            xml.__send__(:"soap:Header") { soap_header(xml) }
            xml.__send__(:"soap:Body") { soap_body(xml) }
          end
        end
      end

      def soap_header(xml)
        xml.__send__(:"secext:Security") do
          xml.__send__(:"secext:UsernameToken") do
            xml.__send__(:"secext:Username", config.client_username)
            xml.__send__(:"secext:Password", "Type" => config.client_password_type) do
              xml.text(config.client_password)
            end
          end
        end
      end

      def ns3_header_rq(xml, provider_username)
        xml.__send__(:"hdr:TransactionRequestID", transaction_request_id)
        xml.__send__(:"hdr:Language", "ENG")
        xml.__send__(:"hdr:UserLoginID", provider_username)
        xml.__send__(:"hdr:UserRole", config.user_role)
      end

      def wsdl_location
        Rails.root.join("app/services/ccms/wsdls/", self.class.wsdl.to_s).to_s
      end

      def config
        Rails.configuration.x.ccms_soa
      end

      def replace_special_characters(xml)
        characters = {
          "’" => "'",
          "‘" => "'",
        }.freeze

        xml.gsub(/[’‘]/, characters)
      end
    end
  end
end
