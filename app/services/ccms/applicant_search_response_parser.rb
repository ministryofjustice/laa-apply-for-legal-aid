module CCMS
  class ApplicantSearchResponseParser < BaseResponseParser
    TRANSACTION_ID_PATH = '//Body//ClientInqRS//HeaderRS//TransactionID'.freeze
    RECORD_COUNT_PATH = '//Body//ClientInqRS//RecordCount//RecordsFetched'.freeze
    APPLICANT_CCMS_REFERENCE_PATH = '//Body//ClientInqRS//Client//ClientReferenceNumber'.freeze

    attr_reader :record_count, :applicant_ccms_reference

    def parse
      raise 'Invalid transaction request id' if extracted_transaction_request_id != @transaction_request_id

      @record_count = extracted_record_count
      @applicant_ccms_reference = extracted_applicant_ccms_reference unless @record_count == '0'
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
