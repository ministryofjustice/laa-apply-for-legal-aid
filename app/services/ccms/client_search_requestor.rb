module CCMS
  class ClientSearchRequestor < BaseRequestor
    NAMESPACES = {
      'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM',
      'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
      'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
      'xmlns:ns4' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
      'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIO'
    }.freeze

    WSDL_LOCATION = "#{File.dirname(__FILE__)}/wsdls/ClientProxyServiceWsdl.xml".freeze

    def initialize
      super(WSDL_LOCATION, NAMESPACES)
    end

    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      @soap_client.call(:get_client_details, xml: request_xml)
    end
    # :nocov:

    private
    # def request_xml
    #   message.to_xml
    # end

    def message
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.__send__('soap:Envelope', NAMESPACES) do
          xml.__send__('soap:Header') { soap_header(xml) }
          xml.__send__('soap:Body') { soap_body(xml) }
        end
      end
    end

    def soap_header(xml)
      xml.__send__('ns1:Security') do
        xml.__send__('ns1:UsernameToken') do
          xml.__send__('ns1:Username', ENV['SOAP_CLIENT_USERNAME'])
          xml.__send__('ns1:Password', 'Type' => ENV['SOAP_CLIENT_PASSWORD_TYPE'] ) { xml.text ENV['SOAP_CLIENT_PASSWORD'] }
        end
      end
    end

    def soap_body(xml)
      xml.__send__('ns2:ClientInqRQ') do
        xml.__send__('ns3:HeaderRQ') { header_request(xml) }
        xml.__send__('ns2:RecordCount') { record_count(xml) }
        xml.__send__('ns2:SearchCriteria') { search_criteria(xml) }
      end
    end

    def header_request(xml)
      xml.__send__('ns3:TransactionRequestID', transaction_request_id)
      xml.__send__('ns3:Language', 'ENG')
      xml.__send__('ns3:UserLoginID', ENV['USER_LOGIN'])
      xml.__send__('ns3:UserRole', ENV['USER_ROLE'])
    end

    def record_count(xml)
      xml.__send__('ns4:MaxRecordsToFetch', 200)
      xml.__send__('ns4:RetriveDataOnMaxCount', false)
    end

    # this is the minimum criteria for a search. nino is also a valid field
    def search_criteria(xml)
      xml.__send__('ns2:ClientInfo') do
        xml.__send__('ns5:FirstName', 'lenovo')
        xml.__send__('ns5:Surname', 'hurlock')
        xml.__send__('ns5:DateOfBirth', '1969-01-01')
      end
    end
  end
end
