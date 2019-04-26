module CCMS
  class ApplicantAddRequestor < BaseRequestor
    def initialize(applicant)
      @applicant = applicant
      @address = applicant.address
      super()
    end

    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      @soap_client.call(:create_client, xml: request_xml)
    end
    # :nocov:

    private

    def request_xml
      soap_envelope(namespaces).to_xml
    end

    def soap_body(xml)
      xml.__send__('ns2:ClientAddRQ') do
        xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml) }
        xml.__send__('ns2:Client') { client(xml) }
      end
    end

    def client(xml)
      xml.__send__('ns5:Name') { name(xml) }
      xml.__send__('ns5:PersonalInformation') { personal_information(xml) }
      xml.__send__('ns5:Contacts') { contacts(xml) }
      xml.__send__('ns5:NoFixedAbode', false)
      xml.__send__('ns5:Address') { address(xml) }
      xml.__send__('ns5:EthnicMonitoring', 0)
    end

    def name(xml)
      xml.__send__('ns4:Surname', @applicant.last_name)
      xml.__send__('ns4:FirstName', @applicant.first_name)
    end

    # this is all mandatory: we don't hold any of this data except date of birth
    def personal_information(xml)
      xml.__send__('ns5:DateOfBirth', @applicant.date_of_birth.strftime('%Y-%m-%d'))
      xml.__send__('ns5:Gender', 'FEMALE')
      xml.__send__('ns5:MaritalStatus', 'U')
      xml.__send__('ns5:VulnerableClient', false)
      xml.__send__('ns5:HighProfileClient', false)
      xml.__send__('ns5:VexatiousLitigant', false)
      xml.__send__('ns5:CountryOfOrigin', 'GBR')
      xml.__send__('ns5:MentalCapacityInd', false)
    end

    # this is the only mandatory item of contact data. i'm not sure what it's for...
    def contacts(xml)
      xml.__send__('ns5:Password', 'Testing')
    end

    def address(xml)
      xml.__send__('ns4:AddressLine1', @address.address_line_one + ' ' + @address.address_line_two)
      xml.__send__('ns4:City', @address.city)
      xml.__send__('ns4:Country', 'GBR')
      xml.__send__('ns4:PostalCode', @address.pretty_postcode)
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
