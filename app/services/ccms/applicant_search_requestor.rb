module CCMS
  class ApplicantSearchRequestor < BaseRequestor
    def initialize(applicant)
      @applicant = applicant
      super()
    end

    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      @soap_client.call(:get_client_details, xml: request_xml)
    end
    # :nocov:

    private

    def request_xml
      soap_envelope(namespaces).to_xml
    end

    def soap_body(xml)
      xml.__send__('ns2:ClientInqRQ') do
        xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml) }
        xml.__send__('ns2:RecordCount') { record_count(xml) }
        xml.__send__('ns2:SearchCriteria') { search_criteria(xml) }
      end
    end

    def record_count(xml)
      xml.__send__('ns4:MaxRecordsToFetch', 200)
      xml.__send__('ns4:RetriveDataOnMaxCount', false)
    end

    def search_criteria(xml)
      xml.__send__('ns2:ClientInfo') do
        xml.__send__('ns5:FirstName', @applicant.first_name)
        xml.__send__('ns5:Surname', @applicant.last_name)
        xml.__send__('ns5:DateOfBirth', @applicant.date_of_birth.strftime('%Y-%m-%d'))
        xml.__send__('ns5:NINumber', @applicant.national_insurance_number)
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
