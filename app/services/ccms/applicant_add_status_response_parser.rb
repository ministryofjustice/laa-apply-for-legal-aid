module CCMS
  class ApplicantAddStatusResponseParser < BaseResponseParser
    TRANSACTION_ID_PATH = '//Body//ClientAddUpdtStatusRS//HeaderRS//TransactionID'.freeze
    STATUS_FREE_TEXT_PATH = '//Body//ClientAddUpdtStatusRS//HeaderRS//Status//StatusFreeText'.freeze
    APPLICANT_CCMS_REFERENCE_PATH = '//Body//ClientInqRS//Client//ClientReferenceNumber'.freeze

    attr_reader :status_free_text, :applicant_ccms_reference

    def parse
      raise CcmsError, 'Invalid transaction request id' if extracted_transaction_request_id != @transaction_request_id

      @status_free_text = extracted_status_free_text
      @applicant_ccms_reference = extracted_applicant_ccms_reference
    end

    def success?
      extracted_status_free_text == 'Party Successfully Created.'
    end

    private

    def extracted_transaction_request_id
      @doc.xpath(TRANSACTION_ID_PATH).text
    end

    def extracted_status_free_text
      @doc.xpath(STATUS_FREE_TEXT_PATH).text
    end

    def extracted_applicant_ccms_reference
      @doc.xpath(APPLICANT_CCMS_REFERENCE_PATH).text
    end
  end
end
