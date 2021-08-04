module CCMS
  module Requestors
    class DocumentIdRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.documentServicesWsdl

      uses_namespaces(
        'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
        'xmlns:secext' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
        'xmlns:casebim' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM',
        'xmlns:hdr' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
        'xmlns:casebio' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIO',
        'xmlns:utility' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
      )

      attr_reader :case_ccms_reference

      def initialize(case_ccms_reference, provider_username, document_type)
        super()
        @case_ccms_reference = case_ccms_reference
        @provider_username = provider_username
        @document_type = document_type
      end

      def call
        soap_client.call(:upload_document, xml: request_xml)
      end

      private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__('casebim:DocumentUploadRQ') do
          xml.__send__('hdr:HeaderRQ') { ns3_header_rq(xml, @provider_username) }
          xml.__send__('casebim:NotificationID', -1)
          xml.__send__('casebim:CaseReferenceNumber', case_ccms_reference)
          xml.__send__('casebim:Document') { document_type(xml) }
        end
      end

      def document_type(xml)
        case @document_type
        when 'bank_transaction_report'
          xml.__send__('casebio:DocumentType', 'BSTMT')
        when 'gateway_evidence_pdf'
          xml.__send__('casebio:DocumentType', 'STATE')
        else
          xml.__send__('casebio:DocumentType', 'ADMIN1')
        end
        xml.__send__('casebio:Channel', 'E')
      end
    end
  end
end
