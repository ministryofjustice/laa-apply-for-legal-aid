module CCMS
  module Requestors
    class ReferenceDataRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.getReferenceDataWsdl

      uses_namespaces(
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIM',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:ns4' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
        'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIO'
      )

      def initialize(provider_username)
        super()
        @provider_username = provider_username
      end

      def call
        soap_client.call(:process, xml: request_xml)
      end

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      private

      def soap_body(xml)
        xml.__send__('ns2:ReferenceDataInqRQ') do
          xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml, @provider_username) }
          xml.__send__('ns2:SearchCriteria') { search_criteria(xml) }
        end
      end

      def search_criteria(xml)
        xml.__send__('ns5:ContextKey', 'CaseReferenceNumber')
        xml.__send__('ns5:SearchKey') do
          xml.__send__('ns5:Key', 'CaseReferenceNumber')
        end
      end
    end
  end
end
