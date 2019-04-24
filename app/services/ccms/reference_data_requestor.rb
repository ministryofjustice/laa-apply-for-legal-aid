module CCMS
  class ReferenceDataRequestor < BaseRequestor
    NAMESPACES = {
    'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
    'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIM',
    'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
    'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
    'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
    'xmlns:ns4' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
    'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIO'
    }.freeze

    WSDL_LOCATION = "#{File.dirname(__FILE__)}/wsdls/GetReferenceDataWsdl.xml".freeze

    def initialize
      super(WSDL_LOCATION, NAMESPACES)
    end

    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      @soap_client.call(:process, xml: message)
    end
    # :nocov:

    private

    def message
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.__send__('soap:Envelope', NAMESPACES) do
          xml.__send__('soap:Header') { soap_header(xml) }
          xml.__send__('soap:Body') { soap_body(xml) }
        end
      end
    end

    def soap_body(xml)
      xml.__send__('ns2:ReferenceDataInqRQ') do
        xml.__send__('ns3:HeaderRQ') { header_request(xml) }
        xml.__send__('ns2:SearchCriteria') { search_criteria(xml) }
      end
    end

    def header_request(xml)
      xml.__send__('ns3:TransactionRequestID', transaction_request_id)
      xml.__send__('ns3:Language', 'ENG')
      xml.__send__('ns3:UserLoginID', ENV['USER_LOGIN'])
      xml.__send__('ns3:UserRole', ENV['USER_ROLE'])
    end

    def search_criteria(xml)
      xml.__send__('ns5:ContextKey', 'CaseReferenceNumber')
      xml.__send__('ns5:SearchKey') do
        xml.__send__('ns5:Key', 'CaseReferenceNumber')
      end
    end
  end
end
