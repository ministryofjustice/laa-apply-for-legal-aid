module CCMS
  class ClientSearchRequestor < BaseRequestor
    NAMESPACES = {
      'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM',
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
      @soap_client.call(:get_client_details, soap_header: header_message, message: body_message)
    end
    # :nocov:

    private

    def request
      @request ||= @soap_client.build_request(:get_client_details, soap_header: header_message, message: body_message)
    end

    def body_message
      {
        'ns3:HeaderRQ' => header_request,
        'ns2:RecordCount' => record_count,
        'ns2:SearchCriteria' => search_criteria
      }
    end

    def header_request
      {
        'ns3:TransactionRequestID' => transaction_request_id,
        'ns3:Language' => 'ENG',
        'ns3:UserLoginID' => ENV['USER_LOGIN'],
        'ns3:UserRole' => ENV['USER_ROLE']
      }
    end

    def record_count
      {
        'ns4:MaxRecordsToFetch' => 200,
        'ns4:RetriveDataOnMaxCount' => false
      }
    end

    # this is the minimum criteria for a search. nino is also a valid field
    def search_criteria
      {
        'ns2:ClientInfo' => {
          'ns5:FirstName' => 'lenovo',
          'ns5:Surname' => 'hurlock',
          'ns5:DateOfBirth' => '1969-01-01'
        }
      }
    end
  end
end
