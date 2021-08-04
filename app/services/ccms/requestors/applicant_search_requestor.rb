module CCMS
  module Requestors
    class ApplicantSearchRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.clientProxyServiceWsdl

      uses_namespaces(
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:clientbim' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:secext' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:hdr' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:common' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
        'xmlns:clientbio' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIO',
        'xmlns:utility' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
      )

      # ns2 -> clientbim
      # ns1 -> secext
      # ns3 -> hdr
      # ns4 -> common
      # ns5 -> clientbio

      def initialize(applicant, provider_username)
        super()
        @applicant = applicant
        @provider_username = provider_username
      end

      def call
        soap_client.call(:get_client_details, xml: request_xml)
      end

      private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__('clientbim:ClientInqRQ') do
          xml.__send__('hdr:HeaderRQ') { ns3_header_rq(xml, @provider_username) }
          xml.__send__('clientbim:RecordCount') { record_count(xml) }
          xml.__send__('clientbim:SearchCriteria') { search_criteria(xml) }
        end
      end

      def record_count(xml)
        xml.__send__('common:MaxRecordsToFetch', 200)
        xml.__send__('common:RetriveDataOnMaxCount', false)
      end

      def search_criteria(xml)
        xml.__send__('clientbim:ClientInfo') do
          xml.__send__('clientbio:FirstName', @applicant.first_name)
          xml.__send__('clientbio:Surname', @applicant.last_name)
          xml.__send__('clientbio:DateOfBirth', @applicant.date_of_birth.to_s(:ccms_date))
          xml.__send__('clientbio:NINumber', @applicant.national_insurance_number)
        end
      end
    end
  end
end
