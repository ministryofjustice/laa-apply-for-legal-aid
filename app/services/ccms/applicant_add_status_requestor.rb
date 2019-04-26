module CCMS
  class CreateClientStatusRequestor < BaseRequestor
    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      @soap_client.call(:get_client_txn_status, message: request_xml)
    end
    # :nocov:

    private

    def request_xml
      soap_envelope(namespaces).to_xml
    end

    def soap_body(xml)
      xml.__send__('ns2:ClientAddUpdtStatusRQ') do
        xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml) }
        xml.__send__('ns2:TransactionID', '20190101121530123456') # this needs to be the transaction id of the create client request
      end
    end

    def namespaces
      {
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:ns4' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
        'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIO'
      }.freeze
    end

    def wsdl_location
      "#{File.dirname(__FILE__)}/wsdls/ClientProxyServiceWsdl.xml".freeze
    end
  end
end
