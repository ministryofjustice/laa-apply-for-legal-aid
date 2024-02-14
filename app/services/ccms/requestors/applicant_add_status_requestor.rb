module CCMS
  module Requestors
    class ApplicantAddStatusRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.clientProxyServiceWsdl

      attr_reader :applicant_add_transaction_id

      def initialize(applicant_add_transaction_id, provider_username)
        super()
        @applicant_add_transaction_id = applicant_add_transaction_id
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
        xml.__send__(:"clientbim:ClientAddUpdtStatusRQ") do
          xml.__send__(:"hdr:HeaderRQ") { ns3_header_rq(xml, @provider_username) }
          xml.__send__(:"clientbim:TransactionID", applicant_add_transaction_id)
        end
      end
    end
  end
end
