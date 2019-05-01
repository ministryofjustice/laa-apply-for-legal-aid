module CCMS
  class ApplicantSearchResponseParser < BaseResponseParser
    TRANSACTION_ID_PATH = '//Body//ClientInqRS//HeaderRS//TransactionID'.freeze
    RECORD_COUNT_PATH = '//Body//ClientInqRS//RecordCount//RecordsFetched'.freeze
    APPLICANT_CCMS_REFERENCE_PATH = '//Body//ClientInqRS//Client//ClientReferenceNumber'.freeze

    def parse
      raise 'Invalid transaction request id' if extracted_transaction_request_id != @transaction_request_id

      extracted_record_count
    end

    def applicant_ccms_reference
      @applicant_ccms_reference ||= extracted_applicant_ccms_reference
    end

    private

    def extracted_transaction_request_id
      @doc.xpath(TRANSACTION_ID_PATH).text
    end

    def extracted_record_count
      @doc.xpath(RECORD_COUNT_PATH).text
    end

    def extracted_applicant_ccms_reference
      @doc.xpath(APPLICANT_CCMS_REFERENCE_PATH).first&.text
    end
  end
end
