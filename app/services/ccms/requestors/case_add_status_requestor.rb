module CCMS
  module Requestors
    class CaseAddStatusRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.caseServicesWsdl

      attr_reader :case_add_transaction_id

      def initialize(case_add_transaction_id, provider_username)
        super()
        @case_add_transaction_id = case_add_transaction_id
        @provider_username = provider_username
      end

      def call
        Faraday::SoapCall.new(wsdl_location, :ccms).call(request_xml)
      end

    private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__(:"casebim:CaseAddUpdtStatusRQ") do
          xml.__send__(:"hdr:HeaderRQ") { ns3_header_rq(xml, @provider_username) }
          xml.__send__(:"casebim:TransactionID", case_add_transaction_id)
        end
      end
    end
  end
end
