module CCMS
  module Parsers
    class BaseResponseParser
      attr_reader :transaction_request_id, :response, :success, :message

      def initialize(tx_request_id, response)
        @transaction_request_id = tx_request_id
        @response = response
        @success = nil
        @message = nil
      end

      def doc
        @doc ||= Nokogiri::XML(response.to_s).remove_namespaces!
      end

      def parse(data_method)
        check_matching_transaction_request_ids if expect_transaction_request_id_in_response?

        extract_result_status
        __send__(data_method)
      end

      def extracted_id_matches_request_id?
        extracted_transaction_request_id == @transaction_request_id
      end

      def text_from(xpath)
        doc.xpath(xpath).text
      end

      private

      def expect_transaction_request_id_in_response?
        true
      end

      def check_matching_transaction_request_ids
        raise CCMSError, "Invalid transaction request id #{extracted_transaction_request_id}" unless extracted_id_matches_request_id?
      end

      def extract_result_status
        if status.present?
          extract_status_code_and_message
        elsif exception.present?
          extract_exception_and_message
        else
          raise CCMSError, 'Unable to find status code or exception in response'
        end
      end

      def status_path
        "/Envelope/Body/#{response_type}/HeaderRS/Status/Status"
      end

      def status
        @status ||= doc.xpath(status_path).text
      end

      def exception
        @exception ||= doc.xpath("/Envelope/Body/#{response_type}/HeaderRS/Status/Exceptions/StatusCode").text
      end

      def extract_status_code_and_message
        @success = status == 'Success'
        @message = "#{status}: #{status_free_text}"
      end

      def extract_exception_and_message
        @success = false
        @message = "Server side exception: #{exception}: #{exception_status_text}"
      end

      def exception_status_text
        doc.xpath("/Envelope/Body/#{response_type}/HeaderRS/Status/Exceptions/StatusText").text
      end

      def status_free_text
        @status_free_text ||= doc.xpath("/Envelope/Body/#{response_type}/HeaderRS/Status/StatusFreeText").text
      end
    end
  end
end
