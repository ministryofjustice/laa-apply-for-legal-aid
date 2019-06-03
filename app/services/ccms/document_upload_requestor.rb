module CCMS
  class DocumentUploadRequestor < BaseRequestor
    wsdl_from 'DocumentServicesWsdl.xml'.freeze

    uses_namespaces(
      'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/',
      'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM',
      'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
      'xmlns:ns4' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIO'
    )

    attr_reader :case_ccms_reference, :ccms_document_id, :document_encoded_base64

    def initialize(case_ccms_reference, ccms_document_id, document_encoded_base64)
      @case_ccms_reference = case_ccms_reference
      @ccms_document_id = ccms_document_id
      @document_encoded_base64 = document_encoded_base64
    end

    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      soap_client.call(:process, xml: request_xml)
    end
    # :nocov:

    private

    def request_xml
      soap_envelope(namespaces).to_xml
    end

    def soap_body(xml)
      xml.__send__('ns2:DocumentUploadRQ') do
        xml.__send__('ns3:HeaderRQ') { ns3_header_rq(xml) }
        xml.__send__('ns2:NotificationID', -1)
        xml.__send__('ns2:CaseReferenceNumber', case_ccms_reference)
        xml.__send__('ns2:Document') { document(xml) }
      end
    end

    def document(xml)
      xml.__send__('ns4:CCMSDocumentID', ccms_document_id)
      xml.__send__('ns4:DocumentType', 'ADMIN1')
      xml.__send__('ns4:FileExtension', 'pdf')
      xml.__send__('ns4:Channel', 'E')
      xml.__send__('ns4:BinData', document_encoded_base64)
    end
  end
end
