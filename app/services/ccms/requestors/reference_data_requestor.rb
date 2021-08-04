module CCMS
  module Requestors
    class ReferenceDataRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.getReferenceDataWsdl

      uses_namespaces(
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:refdatabim' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIM',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:secext' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:hdr' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:common' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
        'xmlns:refdatabio' => 'http://legalservices.gov.uk/CCMS/Common/ReferenceData/1.0/ReferenceDataBIO',
        'xmlns:utility' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
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
        xml.__send__('refdatabim:ReferenceDataInqRQ') do
          xml.__send__('hdr:HeaderRQ') { ns3_header_rq(xml, @provider_username) }
          xml.__send__('refdatabim:SearchCriteria') { search_criteria(xml) }
        end
      end

      def search_criteria(xml)
        xml.__send__('refdatabio:ContextKey', 'CaseReferenceNumber')
        xml.__send__('refdatabio:SearchKey') do
          xml.__send__('refdatabio:Key', 'CaseReferenceNumber')
        end
      end
    end
  end
end
