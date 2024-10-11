module CCMS
  module Requestors
    class DocumentIdRequestor < BaseRequestor
      wsdl_from Rails.configuration.x.ccms_soa.documentServicesWsdl

      attr_reader :case_ccms_reference

      def initialize(case_ccms_reference, provider_username, document_type)
        super()
        @case_ccms_reference = case_ccms_reference
        @provider_username = provider_username
        @document_type = document_type
      end

      def call
        Faraday::SoapCall.new(wsdl_location, :ccms).call(request_xml)
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
          xml.__send__(:"casebim:Document") { document_type(xml) }
        end
      end

      def document_type(xml)
        document_category = DocumentCategory.find_by(name: @document_type)
        if document_category.present?
          xml.__send__(:"casebio:DocumentType", document_category.ccms_document_type)
        else
          xml.__send__(:"casebio:DocumentType", "ADMIN1")
        end
        xml.__send__(:"casebio:Channel", "E")
      end
    end
  end
end
