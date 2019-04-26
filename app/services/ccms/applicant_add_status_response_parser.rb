module CCMS
  class ApplicantAddStatusResponseParser < BaseResponseParser
    TRANSACTION_ID_PATH = '//Body//ClientAddUpdtStatusRS//HeaderRS//TransactionID'.freeze
    STATUS_FREE_TEXT_PATH = '//Body//ClientAddUpdtStatusRS//HeaderRS//Status//StatusFreeText'.freeze

    def parse
      raise 'Invalid transaction request id' if extracted_transaction_request_id != @transaction_request_id

      extracted_status_free_text
    end

    private

    def extracted_transaction_request_id
      @doc.xpath(TRANSACTION_ID_PATH).text
    end

    def extracted_status_free_text
      @doc.xpath(STATUS_FREE_TEXT_PATH).text
    end
  end
end
