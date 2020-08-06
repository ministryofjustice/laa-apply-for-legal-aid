module CCMS
  module Requestors
    class ApplicantAddRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.clientProxyServiceWsdl

      uses_namespaces(
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:ns4' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
        'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIO'
      )

      attr_reader :applicant

      delegate :address, to: :applicant

      def initialize(applicant, provider_username)
        super()
        @applicant = applicant
        @provider_username = provider_username
      end

      def call
        soap_client.call(:create_client, xml: request_xml)
      end

      private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__('ns2:ClientAddRQ') do
          xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml, @provider_username) }
          xml.__send__('ns2:Client') { client(xml) }
        end
      end

      def client(xml)
        xml.__send__('ns5:Name') { name(xml) }
        xml.__send__('ns5:PersonalInformation') { personal_information(xml) }
        xml.__send__('ns5:Contacts') { contacts(xml) }
        xml.__send__('ns5:NoFixedAbode', false)
        xml.__send__('ns5:Address') { applicant_address(xml) }
        xml.__send__('ns5:EthnicMonitoring', 0)
      end

      def name(xml)
        xml.__send__('ns4:Surname', applicant.last_name)
        xml.__send__('ns4:FirstName', applicant.first_name)
      end

      # this is all mandatory: we don't hold any of this data except date of birth
      def personal_information(xml)
        xml.__send__('ns5:DateOfBirth', applicant.date_of_birth.to_s(:ccms_date))
        xml.__send__('ns5:Gender', 'UNSPECIFIED')
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

      def applicant_address(xml)
        xml.__send__('ns4:AddressLine1', address.first_lines)
        xml.__send__('ns4:City', address.city)
        xml.__send__('ns4:Country', 'GBR')
        xml.__send__('ns4:PostalCode', address.pretty_postcode)
      end
    end
  end
end
