module CCMS
  module Requestors
    class ReferenceDataRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.getReferenceDataWsdl

      def initialize(provider_username)
        super()
        @provider_username = provider_username
      end

      def call
        make_faraday_request
      end

      def request_xml
        soap_envelope(namespaces).to_xml
      end

    private

      def soap_body(xml)
        xml.__send__(:"refdatabim:ReferenceDataInqRQ") do
          xml.__send__(:"hdr:HeaderRQ") { ns3_header_rq(xml, @provider_username) }
          xml.__send__(:"refdatabim:SearchCriteria") { search_criteria(xml) }
        end
      end

      def search_criteria(xml)
        xml.__send__(:"refdatabio:ContextKey", "CaseReferenceNumber")
        xml.__send__(:"refdatabio:SearchKey") do
          xml.__send__(:"refdatabio:Key", "CaseReferenceNumber")
        end
      end
    end
  end
end
