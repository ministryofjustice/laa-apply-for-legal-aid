module CCMS
  module Requestors
    class ApplicantAddStatusRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.clientProxyServiceWsdl

      uses_namespaces(
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:clientbim' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:secext' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:hdr' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:common' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
        'xmlns:clientbio' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIO'
      )

      # ns1 -> secext
      # ns2 -> clientbim
      # ns3 -> hdr
      # ns4 -> common
      # ns5 -> clientbio

      attr_reader :applicant_add_transaction_id

      def initialize(applicant_add_transaction_id, provider_username)
        super()
        @applicant_add_transaction_id = applicant_add_transaction_id
        @provider_username = provider_username
      end

      def call
        soap_client.call(:get_client_txn_status, xml: request_xml)
      end

      private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__('clientbim:ClientAddUpdtStatusRQ') do
          xml.__send__('hdr:HeaderRQ') { ns3_header_rq(xml, @provider_username) }
          xml.__send__('clientbim:TransactionID', applicant_add_transaction_id)
        end
      end
    end
  end
end
