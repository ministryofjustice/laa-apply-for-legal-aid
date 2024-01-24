module CCMS
  module Requestors
    class DocumentUploadRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.documentServicesWsdl

      attr_reader :case_ccms_reference, :ccms_document_id, :document_encoded_base64

      def initialize(case_ccms_reference, ccms_document_id, document_encoded_base64, provider_username, document_type = nil)
        super()
        @case_ccms_reference = case_ccms_reference
        @ccms_document_id = ccms_document_id
        @document_encoded_base64 = document_encoded_base64
        @provider_username = provider_username
        @document_type = document_type
      end

      def call
        make_faraday_request
      end

    private

      def request_xml
        soap_envelope(namespaces).to_xml
      end

      def soap_body(xml)
        xml.__send__(:"casebim:DocumentUploadRQ") do
          xml.__send__(:"hdr:HeaderRQ") { ns3_header_rq(xml, @provider_username) }
          xml.__send__(:"casebim:NotificationID", -1)
          xml.__send__(:"casebim:CaseReferenceNumber", case_ccms_reference)
          xml.__send__(:"casebim:Document") { document(xml) }
        end
      end

      def document(xml)
        xml.__send__(:"casebio:CCMSDocumentID", ccms_document_id)
        document_type(xml)
        xml.__send__(:"casebio:Channel", "E")
        xml.__send__(:"casebio:BinData", document_encoded_base64)
      end

      def document_type(xml)
        case @document_type
        when "bank_transaction_report"
          xml.__send__(:"casebio:DocumentType", "BSTMT")
          xml.__send__(:"casebio:FileExtension", "csv")
        when "bank_statement_evidence_pdf"
          xml.__send__(:"casebio:DocumentType", "BSTMT")
          xml.__send__(:"casebio:FileExtension", "pdf")
        when "gateway_evidence_pdf"
          xml.__send__(:"casebio:DocumentType", "STATE")
          xml.__send__(:"casebio:FileExtension", "pdf")
        else
          xml.__send__(:"casebio:DocumentType", "ADMIN1")
          xml.__send__(:"casebio:FileExtension", "pdf")
        end
      end
    end
  end
end
