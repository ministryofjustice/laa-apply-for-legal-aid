module CCMS
  class ReferenceDataRequestor < BaseRequestor
    NAMESPACES = {
      'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIM',
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
      @soap_client.call(:process, soap_header: header_message, message: body_message)
    end
    # :nocov:

    private

    def request
      @request ||= @soap_client.build_request(:process, soap_header: header_message, message: body_message)
    end

    def body_message
      {
        'ns3:HeaderRQ' => header_request,
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

    def search_criteria
      {
        'ns5:ContextKey' => 'CaseReferenceNumber',
        'ns5:SearchKey' => {
          'ns5:Key' => 'CaseReferenceNumber'
        }
      }
    end
  end
end
